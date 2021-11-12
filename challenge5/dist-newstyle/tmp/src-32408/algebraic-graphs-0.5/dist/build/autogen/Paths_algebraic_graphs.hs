{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -Wno-missing-safe-haskell-mode #-}
module Paths_algebraic_graphs (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,5] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/steven/.cabal/store/ghc-8.10.7/algebraic-graphs-0.5-717275921d36b2579fddb1c5b6b0feea7f51264f1105d6fb8c5880e02b87d288/bin"
libdir     = "/home/steven/.cabal/store/ghc-8.10.7/algebraic-graphs-0.5-717275921d36b2579fddb1c5b6b0feea7f51264f1105d6fb8c5880e02b87d288/lib"
dynlibdir  = "/home/steven/.cabal/store/ghc-8.10.7/algebraic-graphs-0.5-717275921d36b2579fddb1c5b6b0feea7f51264f1105d6fb8c5880e02b87d288/lib"
datadir    = "/home/steven/.cabal/store/ghc-8.10.7/algebraic-graphs-0.5-717275921d36b2579fddb1c5b6b0feea7f51264f1105d6fb8c5880e02b87d288/share"
libexecdir = "/home/steven/.cabal/store/ghc-8.10.7/algebraic-graphs-0.5-717275921d36b2579fddb1c5b6b0feea7f51264f1105d6fb8c5880e02b87d288/libexec"
sysconfdir = "/home/steven/.cabal/store/ghc-8.10.7/algebraic-graphs-0.5-717275921d36b2579fddb1c5b6b0feea7f51264f1105d6fb8c5880e02b87d288/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "algebraic_graphs_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "algebraic_graphs_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "algebraic_graphs_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "algebraic_graphs_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "algebraic_graphs_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "algebraic_graphs_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
