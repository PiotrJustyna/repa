{-# LANGUAGE BangPatterns #-}
module Count where
import Page
import Progress
import System.Environment
import qualified Data.ByteString.Lazy.Char8     as BL


-- | Get the maximum page number in the file, 
--   and count the total number of lines.
countPages :: FilePath -> IO (Int, Int)
countPages !filePath
 = do   putStrLn $ "* Counting pages in file."
        bs                     <- BL.readFile filePath
        (lineCount, maxPageId) <- eat (0, 0) (BL.lines bs)
        printPosition True "  lines read: " 10000 lineCount
        putStrLn $ " max page id: " ++ padR 10 (show maxPageId)
        return (lineCount, maxPageId)

 where  eat state []
         = return $ state

        eat (!lineCount, !maxPageId) (l:ls)
         = case BL.readInt l of
            Nothing 
             -> error $ "countPages: parse error on line " ++ show lineCount

            Just (pid', _)
             -> do let !maxPageId' = max pid' maxPageId
                   printPosition False "  lines read: " 10000 lineCount
                   eat (lineCount + 1, maxPageId') ls

