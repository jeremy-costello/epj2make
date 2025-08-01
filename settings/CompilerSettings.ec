#ifdef EC_STATIC
public import static "ecrt"
#else
public import "ecrt"
#endif

import "CompilerConfig"

#ifdef __WIN32__
define settingsDir = "EcereIDE";
#else
define settingsDir = ".ecereIDE";
#endif

class CompilerConfigHolder
{
   CompilerConfigs compilers { };

   property CompilerConfigs compilers
   {
      set { compilers.Free(); delete compilers; compilers = value; }
      get { return compilers; }
   }

   ~CompilerConfigHolder()
   {
      compilers.Free();
   }
}

// REVIEW: Here this is currently only used to figure out the compiler configs path
class CompilerSettingsContainer : GlobalSettings
{
   virtual void onLoadCompilerConfigs();
   virtual void onLoad();

   CompilerConfigs compilerConfigs;

   void getConfigFilePath(char * path, Class _class, char * dir, const char * configName)
   {
      if(dir) *dir = 0;

      if(settingsFilePath)
      {
         strcpy(path, settingsFilePath);
         printf("DEBUG: settingsFilePath is set: %s\n", settingsFilePath);
      }

      StripLastDirectory(path, path);
      printf("DEBUG: Base path after stripping: %s\n", path);

      if(_class == class(CompilerConfig))
      {
         PathCatSlash(path, "compilerConfigs");
         printf("DEBUG: Path after appending 'compilerConfigs': %s\n", path);

         if(dir)
         {
            strcpy(dir, path);
            printf("DEBUG: Set dir to: %s\n", dir);
         }

         if(configName)
         {
            PathCatSlash(path, configName);
            strcat(path, ".econ");
            printf("DEBUG: Final full config path with file: %s\n", path);
         }
      }
   }

private:

   SettingsIOResult Load()
   {
      SettingsIOResult result = error;

      driver = "ECON";
      settingsName = "config";
      settingsExtension = "econ";
      settingsDirectory = settingsDir;
      if(GlobalSettings::OpenAndLock(null))
      {
         result = success;
         CloseAndMonitor();
      }
      return result;
   }
}
