require 'test_helper'

class TestVhostTool < Test::Unit::TestCase

  def setup
    @testdirs_dir = 'test/resources/test_dirs'
    @sites_available = 'test/resources/sites-available'
    @sites_enabled = 'test/resources/sites-enabled'

    @executor = mock("VhostTool::Executor")
    @vhosttool = VhostTool::VhostTool.new(@executor)
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

  def test_creates_user_dirs
    create_testdir_for_currentuser('testdir')
    assert(File.exists?(@testdirs_dir + '/testdir'))
  end

  def test_restarts_apache2 
    @executor.expects(:execute).with('service apache2 restart')
    @vhosttool.restart :apache2
  end

  def test_adds_user
    @executor.expects(:execute).with('useradd -m -g bobsgroup bob')
    @vhosttool.create_user(:bob, :bobsgroup)
  end

  def test_creates_bindfs_mount
    @executor.expects(:execute).twice
    @vhosttool.create_bindfs_mount(@testdirs_dir + '/source',
                                   @testdirs_dir + '/dest',
                                   current_user,
                                   current_user,
                                   current_group)
  end

  protected

  def create_testdir_for_currentuser(dirname)
    @vhosttool.create_dir(@testdirs_dir + "/#{dirname}", current_user, current_group, 0755)
  end

  def current_user
    Etc.getlogin()
  end

  def current_group
    Etc.getgrgid(Etc.getpwnam(current_user()).gid).name
  end

  def cleanup_sites_resources
    if File.exists?(@testdirs_dir)
      FileUtils.rm_rf(@testdirs_dir)
    end

    if File.exists?(@sites_available)
      FileUtils.rm_rf(@sites_available);
    end

    if File.exists?(@sites_enabled)
      FileUtils.rm_rf(@sites_enabled)
    end

    FileUtils.mkdir_p(@testdirs_dir)
    FileUtils.mkdir_p(@sites_available)
    FileUtils.mkdir_p(@sites_enabled)
  end
end
