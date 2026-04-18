This is a re-packaging of Qubes Dom0/DomU packages for NixOS

Use `jj` (jujutsu vcs) for commits, and make sure to include prompt in such commit messages.
Only use `nix` (nix flakes) command to call to nix, avoid legacy commands such as `nix-build`/`nix-shell`/`nix-instantiate`
If Nix can't find some file ("Path ... in the repository ... is not tracked by Git"), use `jj status` to sync the worktree with jj-colocated git repo.

For commits use NixOS commit convention:
For updates: PACKAGE: vOLD -> vNEW
For other changes (e.g patch updates): PACKAGE: CHANGE

Do not merge changes to multiple packages in the same commit, you can use `jj split` to do that.

But suffix your commit messages with (slop) so LLM-generated commits can be identified in jj log, also never forget
Co-Authored-With: trailer with your model name.
