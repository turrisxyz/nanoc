module Nanoc
  class Site

    DEFAULT_CONFIG = {
      :output_dir   => 'output',
      :eruby_engine => 'erb',
      :data_source  => 'filesystem'
    }

    attr_reader :config
    attr_reader :compiler, :data_source
    attr_reader :code, :pages, :page_defaults, :layouts, :templates

    # Creating a Site object

    def self.in_site_dir?
      return false unless File.directory?('tasks')
      return false unless File.file?('config.yaml')
      return false unless File.file?('Rakefile')
      return true
    end

    def self.from_cwd
      in_site_dir? ? new : nil
    end

    def initialize
      # Load configuration
      @config = DEFAULT_CONFIG.merge(YAML.load_file_and_clean('config.yaml'))

      # Create data source
      @data_source_class = PluginManager.data_source_named(@config[:data_source])
      error "Unrecognised data source: #{@config[:data_source]}" if @data_source_class.nil?
      @data_source = @data_source_class.new(self)

      # Create compiler
      @compiler = Compiler.new(self)

      # Set not loaded
      @data_loaded = false
    end

    def load_data_if_necessary
      return if @data_loaded

      # Start data source
      @data_source.up

      # Load data
      @code           = @data_source.code
      @pages          = @data_source.pages.map { |p| Page.new(p, self) }
      @page_defaults  = @data_source.page_defaults
      @layouts        = @data_source.layouts
      @templates      = @data_source.templates

      # Stop data source
      @data_source.down

      # Set loaded
      @data_loaded = true
    end

    # Compiling

    def compile
      load_data_if_necessary
      @compiler.run
    end

    # Creating

    def setup
      @data_source.up
      @data_source.setup
      @data_source.down
    end

    def create_page(name, template_name='default')
      load_data_if_necessary
      template = @templates.find { |t| t[:name] == template_name }
      @data_source.create_page(name, template)
    end

    def create_template(name)
      load_data_if_necessary
      @data_source.create_template(name)
    end

    def create_layout(name)
      load_data_if_necessary
      @data_source.create_layout(name)
    end

  end
end
