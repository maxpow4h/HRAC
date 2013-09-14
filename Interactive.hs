{-# LANGUAGE BangPatterns #-}

-- Interpreter from https://github.com/mchakravarty/language-c-inline
  -- standard libraries
import Prelude hiding (catch)
import Control.Applicative
import Control.Exception

  -- hint
import qualified Language.Haskell.Interpreter as Interp

main = do
  i <- getLine
  x <- eval i
  putStrLn x

-- Evaluate a Haskell expression, 'show'ing its result.
--
-- Each time this function is called a new interpreter context is launched. No state is kept between two subsequent
-- evaluations.
--
-- If GHC raises an error, we pretty print it.
--
eval :: String -> IO String
eval e
  = do 
    {   -- demand the result to force any contained exceptions
    ; !result <- either pprError id <$> (Interp.runInterpreter $ do
                   { Interp.loadModules ["*RACStream"]
                   ; Interp.setTopLevelModules ["RACStream"]
                   ; Interp.typeOf e
                   })
    ; return result
    }
    `catch` (return . (show :: SomeException -> String))
  where
    pprError (Interp.UnknownError msg) = msg
    pprError (Interp.WontCompile errs) = "Compile time error: \n" ++ concatMap Interp.errMsg errs
    pprError (Interp.NotAllowed msg)   = "Permission denied: " ++ msg
    pprError (Interp.GhcException msg) = "Internal error: " ++ msg