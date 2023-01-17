# haddock.vim

Easily add Haddock documentation comments in Vim

## Usage

This plugin provides a few commands to easily add Haddock comments
to your Haskell code.

The `:HaddockDeclaration` command finds the top-level declaration
of the body of code currently under the cursor, starts a Haddock
documentation comment, and leaves you in insert mode.

## Options

Haddock supports 2 styles of comment:

```haskell
-- | A top-level function
function :: Int -> String
function = ...

{-|
  A newtype declaration
-}
newtype MyType = ...
```

The first ("dashed") is the default. To use the second, put the
following line anywhere in your .vimrc:

```vimscript
    let g:HaddockToolkit_style = "curly"
```

## Mappings

The default mappings (enabled only when editing a Haskell file)
are:

  <localleader>hd     - [HaddockDeclaration](#usage)
