#ifdef EC_STATIC
public import static "ecrt"
#else
public import "ecrt"
#endif

public class NamedString : struct
{
public:
   property String name { set { delete name; name = CopyString(value); } get { return name; } }
   property String string { set { delete string; string = CopyString(value); } get { return string; } }
private:
   String name;
   String string;

   ~NamedString()
   {
      delete name;
      delete string;
   }
}

/*static */SettingsIOResult writeConfigFile(const char * path, Class dataType, void * data)
{
   SettingsIOResult result = error;
   SafeFile sf = SafeFile::open(path, write);
   if(sf)
   {
      WriteECONObject(sf.file, dataType, data, 0);
      sf.sync();
      delete sf;
      result = success;
   }
   else
      PrintLn($"error: could not safely open file for writing configuration: ", path);
   return result;
}

/*static */SettingsIOResult readConfigFile(const char * path, Class dataType, void ** data)
{
   SettingsIOResult result = error;
   SafeFile sf;
   if(!FileExists(path))
      result = fileNotFound;
   else if((sf = SafeFile::open(path, read)))
   {
      JSONResult jsonResult;
      {
         ECONParser parser { f = sf.file };
         sf.file.Seek(0, start);
         jsonResult = parser.GetObject(dataType, data);
         if(jsonResult != success)
            delete *data;
         delete parser;
      }
      if(jsonResult == success)
         result = success;
      else
      {
         result = fileNotCompatibleWithDriver;
         PrintLn($"error: could not parse configuration file: ", path);
      }
      delete sf;
   }
   return result;
}

class SafeFile
{
   File file;
   FileOpenMode mode;
   char path[MAX_LOCATION];
   char tmp[MAX_LOCATION];

   SafeFile ::open(const char * path, FileOpenMode mode)
   {
      SafeFile result = null;
      if(mode == write || mode == read)
      {
         SafeFile sf { mode = mode };
         int c;
         bool locked = false;
         FileLock lockType = mode == write ? exclusive : shared;

         strcpy(sf.path, path);
         strcpy(sf.tmp, path);
         strcat(sf.tmp, ".tmp");
         if(mode == write && FileExists(sf.tmp).isFile)
            DeleteFile(sf.tmp);

         if(mode == write)
         {
            sf.file = FileOpen(sf.tmp, readWrite);
            if(!sf.file)
            {
               sf.file = FileOpen(sf.tmp, writeRead);
               if(sf.file)
               {
                  delete sf.file;
                  sf.file = FileOpen(sf.tmp, readWrite);
               }
            }
         }
         else
            sf.file = FileOpen(path, mode);
         if(sf.file)
         {
            for(c = 0; c < 10 && !(locked = sf.file.Lock(lockType, 0, 0, false)); c++) Sleep(0.01);
            if(locked)
            {
               sf.file.Truncate(0);
               sf.file.Seek(0, start);
               result = sf;
            }
            else if(mode == write)
               PrintLn($"warning: SafeFile::open: unable to obtain exclusive lock on temporary file for writing: ", sf.tmp);
            else
               PrintLn($"warning: SafeFile::open: unable to obtain shared lock on file for reading: ", path);
         }
         else if(mode == write)
            PrintLn($"warning: SafeFile::open: unable to open temporary file for writing: ", sf.tmp);
         else
            PrintLn($"warning: SafeFile::open: unable to open file for reading: ", path);

         if(!result)
            delete sf;
      }
      else
         PrintLn($"warning: SafeFile::open: does not yet support FileOpenMode::", mode);
      return result;
   }

   void sync()
   {
      if(file && mode == write)
      {
         int c;
         File f = FileOpen(path, readWrite);
         if(!f)
         {
            f = FileOpen(path, writeRead);
            if(f)
            {
               delete f;
               f = FileOpen(path, readWrite);
            }
         }
         if(f)
         {
            bool locked = true;
            for(c = 0; c < 10 && !(locked = f.Lock(exclusive, 0,0, false)); c++) Sleep(0.01);

            if(locked)
            {
               f.Unlock(0,0, false);
               delete f;
               file.Unlock(0,0, false);
               delete file;

               for(c = 0; c < 10; c++)
               {
                  if(MoveFileEx(tmp, path, { true, true }))
                     break;
                  else
                     Sleep(0.01);
               }
            }
            else
            {
               delete f;
               PrintLn($"warning: SafeFile::sync: failed to lock file for ", mode);
            }
         }
      }
   }


   ~SafeFile()
   {
      if(file)
      {
         file.Unlock(0,0, false);
         delete file;
      }
   }
}
