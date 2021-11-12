{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -Wno-missing-safe-haskell-mode #-}
module Paths_alex (
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
version = Version [3,2,6] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/steven/.cabal/store/ghc-8.10.7/alex-3.2.6-e-alex-1bf08b31fcb3a8f2fc16a9fea811ae17215fe3ef53403677d2c9f416d4b13c9c/bin"
libdir     = "/home/steven/.cabal/store/ghc-8.10.7/alex-3.2.6-e-alex-1bf08b31fcb3a8f2fc16a9fea811ae17215fe3ef53403677d2c9f416d4b13c9c/lib"
dynlibdir  = "/home/steven/.cabal/store/ghc-8.10.7/alex-3.2.6-e-alex-1bf08b31fcb3a8f2fc16a9fea811ae17215fe3ef53403677d2c9f416d4b13c9c/lib"
datadir    = "/home/steven/.cabal/store/ghc-8.10.7/alex-3.2.6-e-alex-1bf08b31fcb3a8f2fc16a9fea811ae17215fe3ef53403677d2c9f416d4b13c9c/share"
libexecdir = "/home/steven/.cabal/store/ghc-8.10.7/alex-3.2.6-e-alex-1bf08b31fcb3a8f2fc16a9fea811ae17215fe3ef53403677d2c9f416d4b13c9c/libexec"
sysconfdir = "/home/steven/.cabal/store/ghc-8.10.7/alex-3.2.6-e-alex-1bf08b31fcb3a8f2fc16a9fea811ae17215fe3ef53403677d2c9f416d4b13c9c/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "alex_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "alex_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "alex_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "alex_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "alex_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "alex_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
