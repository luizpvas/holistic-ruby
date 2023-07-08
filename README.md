# What problem am I trying to solve?

make memory leaks impossible;
make state easy to serialize and restore;
make inconsistency impossible;
with good performance.

## scope

* create: from visitor. insert in symbol index and as children of application's root scope. symbol points to record. record points to its parent and children.
* update: from visitor. new source location is added.
* who knows about it: itself via parent and children. references via type inferece conclusion. dependency map set during type solving. symbols via record subtype.

## reference

* create: from visitor. insert in symbol table. nothing else points to it.

## hypothesis - kill the symbol abstraction

scopes have their own table
references have their own table (consolidate into dependencies)

on file change:
  - delete all scopes
  - delete all references
