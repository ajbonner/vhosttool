require 'test/unit'
require 'vhosttool'
require 'fileutils'
 
class TestVhostTool < Test::Unit::TestCase

  def setup
    @sites_available = 'test/resources/sites-available';
    @sites_enabled = 'test/resources/sites-enabled';

    @vhosttool = vhosttool = VhostTool::VhostTool.new
  end

  def test_processes_template
    template = 'templates/vhost.template'
    vars = { '%DOMAIN%' => 'example.com', '%USER%' => 'bob' }
    contents = @vhosttool.process_template(template, vars)
    assert_match(/example.com/, contents)
    assert_match(/bob/, contents)
  end

  def test_finds_next_vhost_available_in_sequence
    inc = @vhosttool.next_vhostconf_increment('test/resources/test_sites_enabled_increment')
    assert_equal('099', inc)
  end

  def test_sets_initial_increment_in_sequence
    cleanup_sites_resources

    inc = @vhosttool.next_vhostconf_increment(@sites_enabled)
    assert_equal('001', inc)
  end

  def tests_creates_vhost
    cleanup_sites_resources

    @vhosttool.create_vhost(
      'templates/vhost.template', 
      'example.com',
      'sally',
      @sites_available,
      @sites_enabled
    )
    assert(File.exists?(@sites_available + '/example.com'))
    assert(File.exists?(@sites_enabled + '/001-example.com'))
    assert(File.symlink?(@sites_enabled + '/001-example.com'))
  end

  protected

  def cleanup_sites_resources
    if File.exists?(@sites_available)
      FileUtils.rm_rf(@sites_available);
    end

    if File.exists?(@sites_enabled)
      FileUtils.rm_rf(@sites_enabled)
    end

    FileUtils.mkdir_p(@sites_available)
    FileUtils.mkdir_p(@sites_enabled)
  end
end
