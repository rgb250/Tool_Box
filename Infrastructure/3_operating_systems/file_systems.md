# File systems

> **History:** the Multics file hierarchy (1960s) inspired Unix (1969) and its
> "everything is a file" idea; ext2 (1993) $\to$ ext3 journaling (2001) $\to$ ext4
> (2008); copy-on-write designs (ZFS 2005, Btrfs 2009) followed; SSDs (2010s)
> reshaped storage. See the [timeline](../timeline.md#operating-systems).
> Previous: [virtual memory](virtual_memory.md).
> Next chapter: [networking](../4_networking/).

## The abstraction

A disk is an array of **blocks** (512 B-4 KiB sectors) addressed by number. A
**file system** turns this into named, hierarchical, persistent **files**, hiding
block numbers, caching and failures.

$$\text{FS} : \text{paths} \rightharpoonup \text{byte sequences} \qquad
\text{path}=/d_1/d_2/\dots/f$$

## Inodes and directories

Two separate objects:

- **Inode**: the file's metadata and where its data blocks are. It contains:
  owner, permissions, size, timestamps, link count, pointers to data blocks. It does *not*
  contain the file name.
- **Directory**: a special file that is a map $\text{name}\mapsto\text{inode number}$.

Path resolution of `/a/b/c` is a fold over the tree starting at the root inode:

$$\text{inode}(/a/b/c) = D_{\text{inode}(/a/b)}[c], \quad \text{where each } D_x \text{ is a directory's name map}$$

Consequences:

- **Hard link**: another name pointing to the same inode (link count $+1$). The data
  is freed when the count reaches 0 (`rm` is really `unlink`).
- **Symbolic link**: a tiny file containing a path, resolved at access time (can dangle).
- Moving a file within a file system only edits directories, never the data.

```bash
ls -li             # show inode numbers
stat file          # all inode metadata
ln a b ; ln -s a c # hard link, symlink
df -i              # inode usage per file system
```

### Locating data blocks (ext2 style)

The inode holds 12 direct pointers, then a single, double and triple indirect
block. With 4 KiB blocks and 4-byte pointers, one block holds $1024$ pointers:

$$\text{max size}\approx\big(12 + 1024 + 1024^2 + 1024^3\big)\times 4\text{ KiB}\approx 4\text{ TiB}$$

Small files need no indirection (fast), huge ones cost a few extra reads. Modern file
systems (ext4, XFS) use **extents** $(\text{start}, \text{length})$ instead, which is a more
compact description of contiguous runs.

## Permissions

Each inode has an owner, a group and 9 permission bits: $r=4,\,w=2,\,x=1$ for
user, group and others, summed per class:

$$\texttt{rwxr-xr--}=(4+2+1)(4+0+1)(4)=\texttt{754}$$

`chmod 754 file`. For a directory, `x` means "may traverse", `r` "may list".
The kernel checks these on every `open`, using the process's user id.

## Everything is a file

Unix exposes many things through the same `open/read/write` interface (and the
[file descriptor](system_calls.md#file-descriptors) table):

| Path | What it is |
|------|------------|
| `/etc/passwd` | regular file |
| `/dev/sda`, `/dev/null`, `/dev/urandom` | devices |
| `/proc/<pid>/...`, `/sys/...` | kernel and process information, generated on the fly |
| pipes, Unix sockets | communication endpoints |

A single tree is assembled by **mounting**: attaching a file system (a partition,
a USB key, a network share, `tmpfs` in RAM) at a directory: `mount /dev/sdb1 /mnt`.
Layout conventions (`/bin`, `/etc`, `/var`, `/home`...) are in
`Linux/FileSystemHierarchy.pdf`.

## Layers of the I/O stack

```text
 program:  read(fd, buf, n)
   |
 VFS (virtual file system: common interface)
   |
 concrete FS (ext4, XFS, Btrfs, NFS, tmpfs)
   |
 page cache (RAM)                       <- hits avoid the disk
   |
 block layer / I/O scheduler
   |
 device driver -> SSD / HDD / network
```

The **VFS** lets one `read` work on any file system type.

### Page cache

Reads and writes go through a RAM cache of file pages. Free memory is used for
it automatically (`free -h`, column *buff/cache*). Writes are **delayed**
(*write-back*): the data is in RAM first, flushed later. `fsync(fd)` forces it to disk.
Using the [memory hierarchy](../1_hardware/cpu_and_memory.md#the-memory-hierarchy) formula
with a hit rate $h$ for the cache, $t_{\text{avg}} = h\,t_{\text{RAM}} + (1-h)\,t_{\text{disk}}$,
and with $t_{\text{disk}}/t_{\text{RAM}}\sim 10^{3}$, a 99 % hit rate still means
disk misses contribute $\approx 10\times$ more time than hits.

## Crash consistency: journaling

Creating a file touches several structures (inode, directory, bitmap). A crash
in the middle would leave them inconsistent. **Journaling** writes the intended
change to a log first:

1. write the transaction to the journal;
2. mark it committed;
3. apply it to the real structures (checkpoint);
4. free the journal entry.

After a crash, committed transactions are replayed and incomplete ones are
discarded, so each update is **atomic**. Copy-on-write file systems (Btrfs, ZFS)
never overwrite data in place and get snapshots as a by-product.

## Things to remember

- A directory maps names to inodes; the inode holds metadata and data location,
  not the name.
- Hard link = extra name for an inode; `rm` removes a name.
- Permissions: $r=4$, $w=2$, $x=1$, per user/group/other.
- Page cache + write-back make file I/O fast; `fsync` makes it durable.
- Journaling makes metadata updates atomic.

## Exercises

1. `stat` a file, hard-link it, `stat` again: what changed? Delete the original.
2. `ls -l /proc/self/fd`, `cat /proc/cpuinfo`, `head -c 16 /dev/urandom | xxd`.
3. `dd if=/dev/zero of=t bs=1M count=500` then `free -h`: where did memory go?
   Use `sync`, and `echo 3 | sudo tee /proc/sys/vm/drop_caches`.
4. `mount | column -t | head`, `lsblk -f`: identify file system types.
5. Create a 1 GiB sparse file (`truncate -s 1G f`): compare `ls -l` and `du`.

## Going further

- OSTEP: "File Systems", "Crash Consistency: FSCK and Journaling".
- `man 7 inode`, `man 2 stat`.
