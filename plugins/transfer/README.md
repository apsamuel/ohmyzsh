# `transfer` plugin

**NOTICE: The `transfer` plugin is deprecated and will be removed soon, since the [transfer.sh](https://transfer.sh) service will be shutdown on 30th November 30th, 2018. Please move your files to an alternative file sharing service provider.**

----

[`transfer.sh`](https://transfer.sh) is an easy to use file sharing service from the command line

To use it, add `transfer` to the plugins array in your zshrc file:

```zsh
plugins=(... transfer)
```

## Usage

- Transfer a file: `transfer file.txt`.

- Transfer a whole directory (it will be automatically compressed): `transfer dir`.

### Encryption / Decryption

- Encrypt and upload a file with symmetric cipher and create ASCII armored output:

  ```zsh
  transfer file -ca
  ```

- Encrypt and upload directory with symmetric cipher and gpg output:

  ```zsh
  transfer directory -ca
  ```

- Decrypt file:

  ```zsh
  gpg -d file -ca
  ```

- Decrypt directory:

  ```zsh
  gpg -d your_archive.tgz.gpg | tar xz
  ```
