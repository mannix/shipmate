module Shipmate

  class IpaParser

    attr_accessor :ipa_file

    def initialize(ipa_file)
      @ipa_file = ipa_file
    end

    def parse_plist
      ipa_info = nil
      begin
        IPA::IPAFile.open(@ipa_file) do |ipa| 
          ipa_info = ipa.info
        end
      rescue Zip::ZipError => e
        puts e
      end
      ipa_info
    end

    def extract_icon_to_file(ipa_file, icon_file)

      icon_destination = Pathname.new(icon_file)
      begin
        IPA::IPAFile.open(ipa_file) do |ipa| 
          proc_that_returns_icon_data = ipa.icons["Icon.png"] || ipa.icons["Icon@2x.png"] || ipa.icons.values[0]
          File.open(icon_destination, 'wb') do
            |f| f.write proc_that_returns_icon_data.call()
          end
        end
      rescue Zip::ZipError

      end
    end

    def extract_manifest(info_plist_hash)
      manifest = {}
      assets = [{'kind'=>'software-package', 'url'=>'__URL__'},{'kind'=>'display-image','needs-shine'=>false,'url'=>'__URL__'}]
      metadata = {}
      metadata["bundle-identifier"] = info_plist_hash["CFBundleIdentifier"]
      metadata["bundle-version"] = info_plist_hash["CFBundleVersion"]
      metadata["kind"] = "software"
      metadata["title"] = "#{info_plist_hash['CFBundleDisplayName']} #{info_plist_hash['CFBundleVersion']}"
      metadata["subtitle"] = "#{info_plist_hash['CFBundleDisplayName']} #{info_plist_hash['CFBundleVersion']}"

      items = [{"assets"=>assets, "metadata"=>metadata}]
      manifest["items"] = items

      manifest
    end

  end

end