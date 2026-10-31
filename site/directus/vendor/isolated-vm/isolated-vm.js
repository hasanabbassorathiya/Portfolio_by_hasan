'use strict';

// Hostinger's Node build image runs CloudLinux 8 (glibc 2.28) and has no C/C++
// compiler, while every published isolated-vm 5.x prebuild requires glibc >= 2.29
// and cannot be compiled there. Directus only reaches isolated-vm for sandboxed
// API extensions and Flow "Exec" operations, neither of which this deployment
// uses, so this shim keeps the module resolvable and fails loudly if those
// features are ever invoked.
const message =
  'isolated-vm is unavailable in this deployment: prebuilt binaries require glibc >= 2.29 ' +
  'and the Hostinger build image (glibc 2.28) has no compiler. Directus sandboxed API ' +
  'extensions and Flow "Exec" operations are disabled; all collection editing works.';

function unavailable() {
  throw new Error(message);
}

class Isolate {
  constructor() {
    unavailable();
  }
}

class Reference {
  constructor() {
    unavailable();
  }
}

class ExternalCopy {
  constructor() {
    unavailable();
  }
}

class Callback {
  constructor() {
    unavailable();
  }
}

class NativeModule {
  constructor() {
    unavailable();
  }
}

module.exports = { Isolate, Reference, ExternalCopy, Callback, NativeModule };
