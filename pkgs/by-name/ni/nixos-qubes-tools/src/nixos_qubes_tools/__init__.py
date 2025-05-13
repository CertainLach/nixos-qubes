#!/usr/bin/env python3

import asyncio

import qubesadmin
import qubesadmin.exc
import qubesadmin.tools
import qubesadmin.events.utils
from pydantic import BaseModel

from sys import exit
from os import listdir, mkdir
from os.path import isfile, join, islink

from shutil import rmtree, copyfile

parser = qubesadmin.tools.QubesArgumentParser(description = 'Reconcile templates/kernels installed using nix')
parser.add_argument("data")

class Data(BaseModel):
    # name => unpacked kernel
    kernels: dict[str, str]
    default_kernel: str

class KernelManagementData(BaseModel):
    kernel_path: str

kernel_pool = "/var/lib/qubes/vm-kernels"
nix_marker = "MANAGED_BY_NIX"

def check_kernel_name(name):
    if '/' in name:
        raise Exception("invalid kernel name: %s" % name)

def is_kernel_valid(name):
    kernel = join(kernel_pool, name)
    return isfile(join(kernel, "vmlinuz"))

def is_kernel_unused(app, name):
    print("  checking kernel %s usage" % name)
    if app.default_kernel == name:
        print("    it is set as default_kernel")
        return False
    for domain in app.domains:
        if domain.name == 'dom0':
            continue
        if domain.kernel == name:
            print("    it is used as kernel for %s" % domain)
            return False

    return True

def is_kernel_managed(name):
    return isfile(join(kernel_pool, name, nix_marker))
def read_management_data(name) -> KernelManagementData:
    file = join(kernel_pool, name, nix_marker)
    with open(file) as marker:
        return KernelManagementData.model_validate_json(marker)

def remove_kernel(name):
    # Wouldn't be funny if there was a wild / in the name
    check_kernel_name(name)
    rmtree(join(kernel_pool, name))

def try_remove_kernel(app, name):
    print("  trying to remove kernel", name)
    if is_kernel_unused(app, name):
        print("    is unused, removing")
        remove_kernel(name)
        return True
    else:
        print("    will be removed after no active users left")
        return False

def reconcile_kernels(app, data: Data):
    kernels = data.kernels
    default_kernel = data.default_kernel

    wants_to_delete = set()
    for kernel_name in listdir(kernel_pool):
        print("kernel on disk =", kernel_name)

        if not is_kernel_valid(kernel_name):
            print("  is invalid, removing")
            remove_kernel(app)
            continue
        if not is_kernel_managed(kernel_name):
            print("  is unmanaged")
            if kernel_name in kernels:
                print("  but nix wants to manage it... recreating")
                rmtree(join(kernel_pool, kernel_name))
            continue
        print("  is managed by nix")
        if kernel_name not in kernels:
            print("  but not present in target description")
            if not try_remove_kernel(app, kernel_name):
                wants_to_delete.add(kernel_name)
            continue
        managed_data = read_management_data(kernel_name)
        if managed_data == None:
            print("  management data is missing, recreating")
            remove_kernel(kernel_name)
            continue
        if managed_data.kernel_path != kernels[kernel_name]:
            print("  was updated, recreating")
            remove_kernel(kernel_name)
            continue
        print("  is valid, skipping")
        del kernels[kernel_name]
    for kernel_name, kernel_path in kernels.items():
        if '/' in kernel_name:
            print("kernel name should not contain /")
            continue

        kernel = join(kernel_pool, kernel_name)
        print("target kernel =", kernel)
        mkdir(kernel)
        for file in ['default-kernelopts-common.txt', 'initramfs', 'memory-hotplug-supported', 'modules.img', 'vmlinuz']:
            src = join(kernel_path, file)
            dst = join(kernel, file)
            if isfile(src) or islink(src):
                copyfile(src, dst, follow_symlinks=True)
        # Assuming marker file will be synced later than other files, on invalid copy it should copy kernel again.
        with open(join(kernel, "MANAGED_BY_NIX"), "w") as marker:
            marker.write(KernelManagementData(kernel_path = kernel_path).model_dump_json())

    old_kernel = app.default_kernel
    if default_kernel != None and default_kernel != old_kernel:
        app.default_kernel = default_kernel

        if old_kernel in wants_to_delete:
            print("as default kernel was changed, we can now try to delete some kernel again")
            try_remove_kernel(app, old_kernel)

async def main_async(args):
    app = args.app

    with open(args.data) as data_file:
        data = Data.model_validate_json(data_file)

    reconcile_kernels(app, data)

def main(args = None, app = None):
    args = parser.parse_args(args, app=app)

    asyncio.run(main_async(args))
    exit(0)

if __name__ == "__main__":
    main()

