{ config, pkgs, ... }:
{
	imports =
		[ # Include the results of the hardware scan.
		  	./hardware-configuration.nix
		  	#./modules
		];	

	#* GRUB
	boot.loader = { 
		efi.canTouchEfiVariables = true;
		efi.efiSysMountPoint = "/boot";
		grub = { 
			enable = true;
			devices = [ "nodev" ];
			efiSupport = true;
			useOSProber = true;
			theme = pkgs.stdenv.mkDerivation {
			    pname = "distro-grub-themes";
			    version = "3.1";
			    src = pkgs.fetchFromGitHub {
			        owner = "AdisonCavani";
			        repo = "distro-grub-themes";
			        rev = "v3.1";
			        hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
			    };
			installPhase = "cp -r customize/nixos $out";
			};
		};
	};	

	#* USERS
	users.users.caien = {
	    isNormalUser = true;
	    description = "caien";
	    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
	    packages = with pkgs; [];
	};	

	#* PROGRAMS
	programs.dconf.enable = true;
  	#* Hyprland
  	#programs.hyprland.enable = true;

    #* SYSTEM
	environment.systemPackages = with pkgs; [
	    neovim 
	    wget
	    kitty 
	    git
	    udisks2
	    nix-prefetch-git
	    #home-manager
	    home-manager
	    # virtualization
	    qemu
	    qemu_kvm
	    libvirt
	    virt-manager
	    virt-viewer        # A viewer for remote virtual machines
	    dnsmasq            # An integrated DNS, DHCP and TFTP server for small networks
	    vde2               # Virtual Distributed Ethernet, an Ethernet compliant virtual network
	    bridge-utils       # An userspace tool to configure linux bridges 
	    libguestfs         # Tools for accessing and modifying virtual machine disk images
	];

	#* SERVICES
  	services.xserver.enable = true;
	services.xserver.xkb.layout = "us";
	#* PLASMA
	services.desktopManager.plasma6.enable = true;
	services.displayManager.sddm.enable = true;
  	services.displayManager.sddm.theme = "chili";

  	#* UDISKS2
  	services.udisks2.enable = true;
  	services.udisks2.mountOnMedia = true;
  	services.udisks2.settings = {
  	  	"udisks2.conf" = {
  	  	  	defaults.encryption = "luks2";
  	  	  	udisks2.modules = [ "*" ];
  	  	  	udisks2.modules_load_preference = "ondemand";
  	  	};
  	};

	#* Enable CUPS
  	services.printing.enable = true;
  	services.printing.drivers = [ pkgs.brlaser ];  # Brother printer driver
	
  	#* Mount, trash, other functionalities
  	services.gvfs.enable = true;

  	#* Enable Sound
  	sound.enable = true;
  	hardware = {
  	  	pulseaudio.enable = true;
  	  	# Video Support
  	  	opengl = {
  	  	  	enable = true;
  	  	  	driSupport32Bit = true;
  	  	  	driSupport = true;
  	  	};
  	  	# Crypto wallet
  	  	# ledger.enable = true;
  	};

	#* ASUS
	services.asusd.enable = true;
    programs.rog-control-center.enable = true;

	#* CPU mode
    powerManagement = {
        enable = true;
        cpuFreqGovernor = "powersave";  # "ondemand", "powersave", "performance"
    };

	# i2c for https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver
    hardware.i2c.enable = true;
    systemd.services.asus-touchpad-numpad = {
        description = "Activate Numpad inside the touchpad with top right corner switch";
        documentation = ["https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver"];
        path = [ pkgs.i2c-tools ];
        script = ''
            cd ${pkgs.fetchFromGitHub {
                owner = "mohamed-badaoui";
                repo = "asus-touchpad-numpad-driver";
                # These needs to be updated from time to time
                rev = "d80980af6ef776ee6acf42c193689f207caa7968";
                sha256 = "sha256-JM2wrHqJTqCIOhD/yvfbjLZEqdPRRbENv+N9uQHiipc=";
            }}
            # In the last argument here you choose your layout.
            ${pkgs.python3.withPackages(ps: [ ps.libevdev ])}/bin/python asus_touchpad.py m433ia
        '';
        # Probably needed because it fails on boot seemingly because the driver
        # is not ready yet. Alternativly, you can use `sleep 3` or similar in the
        # `script`.
        serviceConfig = {
            RestartSec = "1s";
            Restart = "on-failure";
        };
        wantedBy = [ "multi-user.target" ];
    };

    #* PROPRIOTARY
    #nixpkgs.config.allowUnfree = true;

	#* VIRTUALIZATION
    virtualisation.libvirtd.enable = true;

    #virtualisation.virtualbox.host.enable = true;
    #virtualisation.virtualbox.host.enableExtensionPack = true;
    #virtualisation.virtualbox.guest.enable = true;

	networking.hostName = "nixos"; # Define your hostname.
	# Enable networking
	networking.networkmanager.enable = true;
	# Set your time zone.
	time.timeZone = "Asia/Kathmandu";
	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	system.stateVersion = "24.05"; 
}
