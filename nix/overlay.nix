self: super: {
  repackRpmKernel = self.callPackage ./repackRpmKernel.nix { };

  fedora41Kernel = self.repackRpmKernel {
    kernelSrc = self.fetchurl {
      url = "https://ftp.qubes-os.org/repo/yum/r4.3/current-testing/dom0/fc41/rpm/kernel-qubes-vm-6.6.77-1.qubes.fc41.x86_64.rpm";
      hash = "sha256-aOwJoqb/cFxGXA69RfRUFl/uZIGpRpQcwZ9DsWZ4cqs=";
    };
    modulesSrc = self.fetchurl {
      url = "https://ftp.qubes-os.org/repo/yum/r4.3/current-testing/dom0/fc41/rpm/kernel-modules-6.6.77-1.qubes.fc41.x86_64.rpm";
      hash = "sha256-QHGrYtPoWUU8FrCnKBDr6ls35gGBrNzh7vbHYfsc0Ew=";
    };
    kernelVersion = "6.6.77-1";
    fedoraVersion = "fc41";
  };
}
