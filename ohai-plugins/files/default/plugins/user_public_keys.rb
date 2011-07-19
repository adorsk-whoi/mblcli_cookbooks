provides 'user_public_keys'

require 'etc'

# Initialize mash.
user_public_keys Mash.new

# For each entry in the password file...
Etc.passwd do |entry|

  # If the entry has a home dir...
  if ! entry.dir.empty?
    
    # Make the path to the expected ssh folder.
    ssh_folder = "#{entry.dir}/.ssh"

    ## If the ssh folder exists...
    if File.directory?(ssh_folder)

      # Initialize a mash to hold the entry's key info.
      entry_keys = Mash.new

      # Get the public key files.
      public_key_files = Dir.glob("#{ssh_folder}/*.pub")

      # For each public key file...
      public_key_files.each do |key_file|
        
        # Save the key file contents to the mash.
        entry_keys[File.basename(key_file)] = IO.read(key_file)

        # If we got key data, save it to the main mash.
        if ! entry_keys.empty?
          user_public_keys[entry.name] = entry_keys
        end

      end

    end

  end

end
