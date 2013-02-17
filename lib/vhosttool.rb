require 'fileutils'

module VhostTool

  VERSION = '0.1.0'

  class VhostTool

    def create_vhost(template, domain, user, sites_available, sites_enabled)
      increment = next_vhostconf_increment(sites_enabled)
      contents = process_template(template, { '%DOMAIN%' => domain, '%USER%' => user })
      File.write(sites_available + '/' + domain, contents)
      FileUtils.ln_s(rel(sites_available) + "/" + domain, "#{sites_enabled}/#{increment}-#{domain}")
    end

    def restart(service_name)
      %x[service #{service_name} reload]
    end

    def create_user(user, group)
      %x[useradd -m -g #{group} #{user}]
    end

    def create_dir(dir, user, group, permissions)
      FileUtils.mkdir_p(dir)
      FileUtils.chown(user, group, dir)
      FileUtils.chmod(permissions, dir)
    end

    def create_bindfs_mount(src_mount, dst_mount, src_user, dst_user, group)
      unless Dir.exists?(dst_mount)
        FileUtils.mkdir_p(dst_mount)
        FileUtils.chown(dst_user, group, dst_mount)
      end
      bindfs_cmd = "bindfs -o perms=0770,mirror-only=#{dst_user}:#{src_user},create-for-user=#{src_user},create-for-group=#{group} #{src_mount} #{dst_mount}"
      %x[echo #{bindfs_cmd} >> /etc/init/mount-bindfs.conf]
      %x[#{bindfs_cmd}]
    end

    def next_vhostconf_increment(path)
      increments = []

      entries = Dir.entries(path)
      entries.each do |entry|
        if File.symlink?(path + '/' + entry)
          increments.push(entry.sub!(/([0-9]+)-.*$/, '\1').to_i)
        end
      end

      unless increments.empty?
        increments.sort!
        inc = increments.pop + 1
      else
        inc = 1
      end

      # convert our inc to string and 0 pad to 3 digits
      inc.to_s.rjust(3, '0')
    end

    def process_template(template_file, replacement_vars)
      contents = File.read(template_file)
      replacement_vars.each { |k,v| contents.gsub!(k,v) }
      return contents
    end


    protected

    def rel(full_path)
      return "../" + File.basename(full_path) 
    end
  end

end
