{
  fetchpatch,
  version,
  revision,
}:

let
  hashes = builtins.fromJSON (builtins.readFile ./patches.json);

  qubesPatch =
    {
      name,
      tag ? "${version}-${revision}",
      type ? "qubes",
      hash ? hashes.${name},
    }:
    (fetchpatch {
      inherit name;
      url = "https://raw.githubusercontent.com/QubesOS/qubes-vmm-xen/refs/tags/v${tag}/${name}.patch";
      inherit hash;
      passthru.type = type;
    });
in
{
  # We obviously don't need Fedora-specific patches, so this is only included here for completeness.
  FEDORA = [ ];
  EFI_WORKAROUNDS = [
    (qubesPatch {
      name = "0200-EFI-early-Add-noexit-to-inhibit-calling-ExitBootServ";
    })
    (qubesPatch {
      name = "0201-efi-Ensure-incorrectly-typed-runtime-services-get-ma";
    })
    (qubesPatch {
      name = "0202-Add-xen.cfg-options-for-mapbs-and-noexitboot";
    })
    (qubesPatch {
      name = "0203-xen.efi.build";
    })
  ];
  BACKPORTS = [
    (qubesPatch {
      name = "0300-xen-list-add-LIST_HEAD_RO_AFTER_INIT";
    })
    (qubesPatch {
      name = "0301-x86-mm-add-API-for-marking-only-part-of-a-MMIO-page-";
    })
    (qubesPatch {
      name = "0302-drivers-char-Use-sub-page-ro-API-to-make-just-xhci-d";
    })
    (qubesPatch {
      name = "0303-x86-S3-restore-MCE-APs-init";
    })
    (qubesPatch {
      name = "0304-x86-time-do-not-kill-calibration-timer-on-suspend";
    })
  ];
  # We already get XSA patches from Xen, so this is only included here for completeness.
  SECURITY_FIXES = [
    (qubesPatch {
      name = "0500-xsa480";
    })
    (qubesPatch {
      name = "0501-xsa488-4.20";
    })
  ];
  UPSTREAMABLE_PATCHES = [
    (qubesPatch {
      name = "0600-libxl-create-writable-error-xenstore-dir";
    })
    (qubesPatch {
      name = "0601-libxl-do-not-wait-for-backend-on-PCI-remove-when-bac";
    })
    (qubesPatch {
      name = "0602-libvchan-use-xengntshr_unshare-instead-of-munmap-dir";
    })
    (qubesPatch {
      name = "0603-x86-time-Don-t-use-EFI-s-GetTime-call-by-default";
    })
    (qubesPatch {
      name = "0604-libxl-automatically-enable-gfx_passthru-if-IGD-is-as";
    })
    (qubesPatch {
      name = "0605-autoconf-fix-handling-absolute-PYTHON-path";
    })
    (qubesPatch {
      name = "0606-libxl-do-not-require-filling-backend_domid-to-remove";
    })
    (qubesPatch {
      name = "0607-libxl-add-pcidevs-to-stubdomain-earlier";
    })
    (qubesPatch {
      name = "0609-vchan-socket-proxy-add-reconnect-marker-support";
    })
    (qubesPatch {
      name = "0610-tools-libxl-enable-in-band-reconnect-marker-for-stub";
    })
    (qubesPatch {
      name = "0611-libxl-Add-a-utility-function-for-domain-resume";
    })
    (qubesPatch {
      name = "0612-libxl-Properly-suspend-stubdomains";
    })
    (qubesPatch {
      name = "0613-libxl-Fix-race-condition-in-domain-suspension";
    })
    (qubesPatch {
      name = "0614-libxl-Add-additional-domain-suspend-resume-logs";
    })
    (qubesPatch {
      name = "0615-libxl-workaround-for-Windows-PV-drivers-removing-con";
    })
    (qubesPatch {
      name = "0616-libxl-check-control-feature-before-issuing-pvcontrol";
    })
    (qubesPatch {
      name = "0617-tools-kdd-mute-spurious-gcc-warning";
    })
    (qubesPatch {
      name = "0618-libxl-do-not-start-qemu-in-dom0-just-for-extra-conso";
    })
    (qubesPatch {
      name = "0619-libxl-Allow-stubdomain-to-control-interupts-of-PCI-d";
    })
    (qubesPatch {
      name = "0620-Validate-EFI-memory-descriptors";
    })
    (qubesPatch {
      name = "0621-x86-mm-make-code-robust-to-future-PAT-changes";
    })
    (qubesPatch {
      name = "0622-Drop-ELF-notes-from-non-EFI-binary-too";
    })
    (qubesPatch {
      name = "0623-xenpm-Factor-out-a-non-fatal-cpuid_parse-variant";
    })
    (qubesPatch {
      name = "0624-x86-idle-Get-PC-8.10-counters-for-Tiger-and-Alder-La";
    })
    (qubesPatch {
      name = "0625-x86-ACPI-Ignore-entries-marked-as-unusable-when-pars";
    })
    (qubesPatch {
      name = "0626-x86-msr-Allow-hardware-domain-to-read-package-C-stat";
    })
    (qubesPatch {
      name = "0627-x86-mwait-idle-Use-ACPI-for-CPUs-without-hardcoded-C";
    })
    (qubesPatch {
      name = "0628-libxl_pci-Pass-power_mgmt-via-QMP";
    })
    (qubesPatch {
      name = "0629-python-avoid-conflicting-_FORTIFY_SOURCE-values";
    })
    (qubesPatch {
      name = "0630-libxl-extend-IGD-check";
    })
    (qubesPatch {
      name = "0631-libxl-Skip-missing-legacy-IRQ";
    })
    (qubesPatch {
      name = "0632-libxl-do-not-consider-IGD-VF-a-VGA-passthru";
    })
    (qubesPatch {
      name = "0633-EFI-Fix-relocating-ESRT-for-dom0";
    })
    (qubesPatch {
      name = "0634-libxl-constify-some-local-variables-to-appease-gcc-1";
    })
  ];
  QUBES_SPECIFIC_PATCHES = [
    (qubesPatch {
      name = "1000-Do-not-access-network-during-the-build";
    })
    (qubesPatch {
      name = "1001-hotplug-store-block-params-for-cleanup";
    })
    (qubesPatch {
      name = "1002-libxl-do-not-start-dom0-qemu-when-not-needed";
    })
    (qubesPatch {
      name = "1003-libxl-do-not-start-qemu-in-dom0-if-possible";
    })
    (qubesPatch {
      name = "1004-systemd-enable-xenconsoled-logging-by-default";
    })
    (qubesPatch {
      name = "1005-hotplug-trigger-udev-event-on-block-attach-detach";
    })
    (qubesPatch {
      name = "1006-libxl-use-EHCI-for-providing-tablet-USB-device";
    })
    (qubesPatch {
      name = "1007-libxl-allow-kernel-cmdline-without-kernel-if-stubdom";
    })
    (qubesPatch {
      name = "1008-libxl-Force-emulating-readonly-disks-as-SCSI";
    })
    (qubesPatch {
      name = "1009-tools-xenconsole-replace-ESC-char-on-xenconsole-outp";
    })
    (qubesPatch {
      name = "1010-libxl-disable-vkb-by-default";
    })
    (qubesPatch {
      name = "1011-Always-allocate-domid-sequentially-and-do-not-reuse-";
    })
    (qubesPatch {
      name = "1012-libxl-add-qubes-gui-graphics";
    })
    (qubesPatch {
      name = "1013-Additional-support-in-ACPI-builder-to-support-SLIC-a";
    })
    (qubesPatch {
      name = "1014-libxl-conditionally-allow-PCI-passthrough-on-PV-with";
    })
    (qubesPatch {
      name = "1015-gnttab-disable-grant-tables-v2-by-default";
    })
    (qubesPatch {
      name = "1016-cpufreq-enable-HWP-by-default";
    })
    (qubesPatch {
      name = "1017-Fix-IGD-passthrough-with-linux-stubdomain";
    })
    (qubesPatch {
      name = "1018-x86-Use-Linux-s-PAT";
    })
  ];
  OTHERS = [
    (qubesPatch {
      name = "1100-Define-build-dates-time-based-on-SOURCE_DATE_EPOCH";
    })
    (qubesPatch {
      name = "1101-docs-rename-DATE-to-PANDOC_REL_DATE-and-allow-to-spe";
    })
    (qubesPatch {
      name = "1102-docs-xen-headers-use-alphabetical-sorting-for-incont";
    })
    (qubesPatch {
      name = "1103-Strip-build-path-directories-in-tools-xen-and-xen-ar";
    })
    (qubesPatch {
      name = "1200-hypercall-XENMEM_get_mfn_from_pfn";
    })
    (qubesPatch {
      name = "1201-patch-gvt-hvmloader.patch";
    })
    (qubesPatch {
      name = "1202-libxl-Add-partially-Intel-GVT-g-support-xengt-device";
    })
  ];
  UNUSED = [
    (qubesPatch {
      name = "1020-xen-tools-qubes-vm";
    })
  ];
}
