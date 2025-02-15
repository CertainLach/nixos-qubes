self: super: {
  python3 = super.python3.override { packageOverrides = import ./python-overlay.nix; };

  qemu_qubes = self.lib.lowPrio (
    self.qemu.override {
      hostCpuTargets = [ "i386-softmmu" ];
      xenSupport = true;
      xen = self.qubes-vmm-xen;
    }
  );
}
