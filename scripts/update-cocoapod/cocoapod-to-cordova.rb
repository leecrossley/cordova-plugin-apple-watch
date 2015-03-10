require 'rexml/document'

# Public CocoapodToCordovaBuilder: Helps to build an Plugman compatible Apache
# Cordova plugin.
#
# Examples
#
#   build = CocoapodToCordovaBuilder.new('MyPod', my_xcode_project)
#   build.root_path = File.expand_path(File.join('.', '..'))
#   build.destination = "src/ios/vendor"
#   build.update_plugin!
class CocoapodToCordovaBuilder
  attr_accessor :config
  attr_reader   :target, :plugin_xml
  attr_writer   :destination, :sourced_attribute, :root_path

  # Public: initialize - setup a new plugin builder.
  #
  # pod_name - string that is the exact name of the pod specified in the podfile
  # xcode_project - See: https://github.com/CocoaPods/Xcodeproj
  #                 The xcode_project object that is passed into the post_install
  #                 hook in a cocoapod podfile.
  #
  # Examples
  #
  #  In podfile~
  #    post_install |installer| do
  #      build = PluginmanCocoapodBuilder.new('podName', installer.project)
  #    end
  #
  # returns an instance of this class ready to be configured
  # raises an error if the xcode_project doesn't contain a target for the pod
  def initialize(pod_name, xcode_project)
    @config = {}
    @pod_name = pod_name
    @target = xcode_project.targets
                           .find{|t| t.display_name == "Pods-#{@pod_name}"}
    return raise "Could not find a build target in xcodeproj" unless target
  end

  # Public: root_path - Set the root_path of the project. This is the same
  #         directory where the plugin.xml file is located
  #
  # setter - A string representing the path to the directory with plugin.xml
  #
  # Examples
  #
  #  build.root_path = "~/Workspace/cordova-plugin"
  #
  def root_path
    @root_path ||= File.expand_path(File.join('.', '../..'))
  end

  # Public: desination - The build output directory. Usually 'src/ios/vendor'
  #
  # setter - A string representing the build output path. The path is
  #          relative sub directory of the root_path of the project.
  #
  # Examples
  #
  #  build.destination = 'src/ios/my-pod-source'
  #
  def destination
    @destination ||= 'src/ios/vendor'
  end

  # Public: configure - configures the build process.
  #
  # options - a hash of configuration options
  #
  # Examples
  #
  #  build.configure({
  #    product: { name: 'libmypod.a', sub_dir: 'lib'},
  #    localization: 'es',
  #    headers: { exclude: ['header-1.h', 'header-5.h'] },
  #    resources: { sub_dir: 'assets' }
  #  })
  #
  def configure(options)
    @config.merge!(options) if options.is_a? Hash
  end

  # Public: update_plugin! - runs the build tool. Will overwrite previously
  #         written elements in plugin.xml and setup extra build phases in
  #         the xcode_project. Copies files to their destination. This will
  #         not build / compile the xcodeproject. To do that, run `make build`
  #
  # Examples
  #
  #  build.update_plugin!
  #
  def update_plugin!
    reset_xml
    include_frameworks @config[:frameworks] || {}
    include_headers @config[:headers] || {}

    resource_options = @config[:resources] || {}
    resource_options[:localization] = @config[:localization] if @config[:localization]

    include_product @config[:product] || {}
    write_plugin_xml! @config[:plugin_xml]
    write_build_target_file!
  end

  private

  def include_product(options={})
    options[:sub_dir] ||= ''
    original_product_name = File.basename(@target.product_reference.path)
    new_product_name = options[:name] || original_product_name
    original_product_path = File.join(dst_path, @target.product_reference.path)
    copy_to_product_path = File.join(dst_path, options[:sub_dir], original_product_name)
    new_product_path = File.join(dst_path, options[:sub_dir], new_product_name)
    new_product_path_relative = File.join(destination, options[:sub_dir], new_product_name)
    if copy_files?(options)
      copy_phase = create_new_copy_files_build_phase(File.dirname(copy_to_product_path))
      copy_phase.add_file_reference(@target.product_reference)
    end
    if write_xml?(options)
        ios_xml_element.add_element(pod_element 'source-file',
                                    {'framework' => 'true',
                                     'src'       => new_product_path_relative})
    end
    if new_product_path != original_product_path
      shell_phase = @target.new_shell_script_build_phase
      shell_phase.show_env_vars_in_log = "0"
      shell_phase.shell_script = "mv #{copy_to_product_path} #{new_product_path}"
    end
    File.open('product_path.txt', 'w') do |f|
      f.puts new_product_path
    end
  end

  def include_headers(options = {})
    options[:sub_dir] ||= 'headers'
    excluded_files = options[:exclude] || []
    if copy_files?(options)
      copy_phase = create_new_copy_files_build_phase(File.join(dst_path, options[:sub_dir]))
    end
    @target.headers_build_phase.files.each do |header|
      header_name = File.basename(header.file_ref.path)
      unless excluded_files.include?(header_name)
        if write_xml?(options)
          header_path = File.join(destination,
                                  options[:sub_dir],
                                  header_name)
          ios_xml_element.add_element(pod_element('header-file',
                                                  {'src' => header_path}))
        end
        if copy_files?(options)
          copy_phase.add_file_reference(header.file_ref)
        end
      end
    end
  end

  def include_frameworks(options={})
    excluded_files = options[:exclude] || []
    @target.frameworks_build_phase.files.each do |framework|
      unless excluded_files.include?(framework.display_name)
        ios_xml_element.add_element(pod_element 'framework',
                                                {'src' => framework.display_name})
      end
    end
  end

  def reset_xml
    ios_xml_element.each_element_with_attribute(sourced_attribute, "true") do |h|
      h.remove
    end
  end

  def write_plugin_xml!(out_name=nil)
    out_name ||= 'plugin.xml'
    File.open(File.join(root_path, out_name), 'w') do |file|
      plugin_xml.context[:attribute_quote] = :quote
      plugin_xml.write(file, 2)
    end
  end

  # This doesn't work from inside the post_install callback. The xcode
  # project is not build yet. Instead we write the target and use the shell.
  # def exec_xcodebuild!
    # exec("cd Pods && xcodebuild -target #{@target.display_name} && cd ..")
  # end

  def write_build_target_file!
    File.open('build_target_name.txt', 'w') do |f|
      f.puts @target.display_name
    end
  end

  def sourced_attribute
    @sourced_attribute ||= 'autogen'
  end

  # Setup paths
  def dst_path
    @dst_path ||= File.join(root_path, destination)
  end

  def plugin_xml
    @plugin_xml ||= REXML::Document.new(File.new(File.join(root_path, 'plugin.xml')))
  end

  def ios_xml_element
    @ios_xml_element ||= REXML::XPath.first(plugin_xml, "//platform[@name='ios']")
  end

  def copy_files?(options)
    options[:copy_files] != false
  end

  def write_xml?(options)
    options[:write_xml] != false
  end

  def create_new_copy_files_build_phase(copy_to_path)
    copy_phase = @target.new_copy_files_build_phase
    copy_phase.dst_subfolder_spec = nil
    copy_phase.dst_path = copy_to_path
    copy_phase
  end

  def pod_element(tag_name, attrs={})
    attrs[sourced_attribute] = "true"
    element = REXML::Element.new(tag_name)
    element.add_attributes(attrs)
    element
  end
end
