#ifdef EC_STATIC
public import static "ecrt"
#else
public import "ecrt"
#endif

import "configFiles"

import "CompilerSettings"

define defaultCompilerName = "Default";

define makeDefaultCommand = (__runtimePlatform == win32) ? "mingw32-make" :
#ifdef __FreeBSD__
   "gmake";
#else
   "make";
#endif

define defaultObjDirExpression = "obj/$(CONFIG).$(PLATFORM)$(COMPILER_SUFFIX)$(DEBUG_SUFFIX)";

define ecpDefaultCommand = "ecp";
define eccDefaultCommand = "ecc";
define ecsDefaultCommand = "ecs";
define earDefaultCommand = "ear";
define cppDefaultCommand = "gcc"; // As per #624 we decided to default to "gcc"...
define ccDefaultCommand = "gcc";
define cxxDefaultCommand = "g++";
//define ldDefaultCommand = "gcc";
define arDefaultCommand = "ar";
define objectDefaultFileExt = "o";
define outputDefaultFileExt = "";

static const char * compilerTypeNames[CompilerType] = { "GCC", "TCC", "PCC", "VS8", "VS9", "VS10" };
static const char * compilerTypeVersionString[CompilerType] = { "", "", "", "8.00", "9.00", "10.00" };
static const char * compilerTypeSolutionFileVersionString[CompilerType] = { "", "", "", "9.00", "10.00", "11.00" };
static const char * compilerTypeYearString[CompilerType] = { "", "", "", "2005", "2008", "2010" };
static const char * compilerTypeProjectFileExtension[CompilerType] = { "", "", "", "vcproj", "vcproj", "vcxproj" };
// TODO: i18n with Array
static Array<const String> compilerTypeLongNames
{ [
   $"GNU Compiler Collection (GCC) / GNU Make",
   $"Tiny C Compiler / GNU Make",
   $"Portable C Compiler / GNU Make",
   $"Microsoft Visual Studio 2005 (8.0) Compiler",
   $"Microsoft Visual Studio 2008 (9.0) Compiler",
   $"Microsoft Visual Studio 2010 (10.0) Compiler"
] };
const CompilerType firstCompilerType = gcc;
const CompilerType lastCompilerType = vs10;
public enum CompilerType
{
   gcc, tcc, pcc, vs8, vs9, vs10;

   property bool isVC
   {
      get { return this == vs8 || this == vs9 || this == vs10; }
   }

   property const char *
   {
      get { return OnGetString(null, null, null); }
      set
      {
         if(value)
         {
            CompilerType c;
            for(c = firstCompilerType; c <= lastCompilerType; c++)
               if(!strcmpi(value, compilerTypeNames[c]))
                  return c;
         }
         return gcc;
      }
   };

   property const char * longName { get { return getString(null, 1); } };
   property const char * versionString { get { return getString(null, 2); } };
   property const char * yearString { get { return getString(null, 3); } };
   property const char * projectFileExtension { get { return getString(null, 4); } };
   property const char * solutionFileVersionString { get { return getString(null, 5); } };

   private static const char * getString(char * tempString, int stringType)
   {
      if(this >= firstCompilerType && this <= lastCompilerType)
      {
         if(tempString)
            strcpy(tempString, compilerTypeNames[this]);
         if(stringType == 0)
            return compilerTypeNames[this];
         else if(stringType == 1)
            return compilerTypeLongNames[this];
         else if(stringType == 2)
            return compilerTypeVersionString[this];
         else if(stringType == 3)
            return compilerTypeYearString[this];
         else if(stringType == 4)
            return compilerTypeProjectFileExtension[this];
         else if(stringType == 5)
            return compilerTypeSolutionFileVersionString[this];
      }
      return null;
   }

   const char * OnGetString(char * tempString, void * fieldData, ObjectNotationType * onType)
   {
      return getString(tempString, 0);
   }
};

class CompilerConfig
{
   class_no_expansion;

   numJobs = 1;
public:
   property const char * name
   {
      set { delete name; if(value) name = CopyString(value); }
      get { return name; }
   }
   bool readOnly;
   CompilerType type;
   Platform targetPlatform;
   int numJobs;
   property const char * makeCommand
   {
      set { delete makeCommand; if(value && value[0]) makeCommand = CopyString(value); }
      get { return makeCommand; }
      isset { return makeCommand && makeCommand[0]; }
   }
   property const char * ecpCommand
   {
      set { delete ecpCommand; if(value && value[0]) ecpCommand = CopyString(value); }
      get { return ecpCommand; }
      isset { return ecpCommand && ecpCommand[0]; }
   }
   property const char * eccCommand
   {
      set { delete eccCommand; if(value && value[0]) eccCommand = CopyString(value); }
      get { return eccCommand; }
      isset { return eccCommand && eccCommand[0]; }
   }
   property const char * ecsCommand
   {
      set { delete ecsCommand; if(value && value[0]) ecsCommand = CopyString(value); }
      get { return ecsCommand; }
      isset { return ecsCommand && ecsCommand[0]; }
   }
   property const char * earCommand
   {
      set { delete earCommand; if(value && value[0]) earCommand = CopyString(value); }
      get { return earCommand; }
      isset { return earCommand && earCommand[0]; }
   }
   property const char * cppCommand
   {
      set { delete cppCommand; if(value && value[0]) cppCommand = CopyString(value); }
      get { return cppCommand; }
      isset { return cppCommand && cppCommand[0]; }
   }
   property const char * ccCommand
   {
      set { delete ccCommand; if(value && value[0]) ccCommand = CopyString(value); }
      get { return ccCommand; }
      isset { return ccCommand && ccCommand[0]; }
   }
   property const char * cxxCommand
   {
      set { delete cxxCommand; if(value && value[0]) cxxCommand = CopyString(value); }
      get { return cxxCommand; }
      isset { return cxxCommand && cxxCommand[0]; }
   }
   property const char * arCommand
   {
      set { delete arCommand; if(value && value[0]) arCommand = CopyString(value); }
      get { return arCommand; }
      isset { return arCommand && arCommand[0]; }
   }
   property const char * ldCommand
   {
      set { delete ldCommand; if(value && value[0]) ldCommand = CopyString(value); }
      get { return ldCommand; }
      isset { return ldCommand && ldCommand[0]; }
   }
   property const char * objectFileExt
   {
      set { delete objectFileExt; if(value && value[0]) objectFileExt = CopyString(value); }
      get { return objectFileExt && objectFileExt[0] ? objectFileExt : objectDefaultFileExt ; }
      isset { return objectFileExt && objectFileExt[0] && strcmp(objectFileExt, objectDefaultFileExt); }
   }
   property const char * staticLibFileExt
   {
      set { delete staticLibFileExt; if(value && value[0]) staticLibFileExt = CopyString(value); }
      get { return staticLibFileExt; }
      isset { return staticLibFileExt && staticLibFileExt[0]; }
   }
   property const char * sharedLibFileExt
   {
      set { delete sharedLibFileExt; if(value && value[0]) sharedLibFileExt = CopyString(value); }
      get { return sharedLibFileExt; }
      isset { return sharedLibFileExt && sharedLibFileExt[0]; }
   }
   property const char * executableFileExt
   {
      set { delete executableFileExt; if(value && value[0]) executableFileExt = CopyString(value); }
      get { return executableFileExt; }
      isset { return executableFileExt && executableFileExt[0]; }
   }
   property const char * executableLauncher
   {
      set { delete executableLauncher; if(value && value[0]) executableLauncher = CopyString(value); }
      get { return executableLauncher; }
      isset { return executableLauncher && executableLauncher[0]; }
   }
   // TODO: implement CompilerConfig::windresCommand
   bool ccacheEnabled;
   bool distccEnabled;
   // deprecated
   property bool supportsBitDepth { set { } get { return true; } isset { return false; } }

   property const char * distccHosts
   {
      set { delete distccHosts; if(value && value[0]) distccHosts = CopyString(value); }
      get { return distccHosts; }
      isset { return distccHosts && distccHosts[0]; }
   }
   property const char * gnuToolchainPrefix
   {
      set { delete gnuToolchainPrefix; if(value && value[0]) gnuToolchainPrefix = CopyString(value); }
      get { return gnuToolchainPrefix; }
      isset { return gnuToolchainPrefix && gnuToolchainPrefix[0]; }
   }
   property const char * sysroot
   {
      set { delete sysroot; if(value && value[0]) sysroot = CopyString(value); }
      get { return sysroot; }
      isset { return sysroot && sysroot[0]; }
   }
   bool resourcesDotEar;
   bool noStripTarget;
   property Array<String> includeDirs
   {
      set
      {
         includeDirs.Free();
         if(value)
         {
            delete includeDirs;
            includeDirs = value;
         }
      }
      get { return includeDirs; }
      isset { return includeDirs.count != 0; }
   }
   property Array<String> libraryDirs
   {
      set
      {
         libraryDirs.Free();
         if(value)
         {
            delete libraryDirs;
            libraryDirs = value;
         }
      }
      get { return libraryDirs; }
      isset { return libraryDirs.count != 0; }
   }
   property Array<String> executableDirs
   {
      set
      {
         executableDirs.Free();
         if(value)
         {
            delete executableDirs;
            executableDirs = value;
         }
      }
      get { return executableDirs; }
      isset { return executableDirs.count != 0; }
   }
   property Array<NamedString> environmentVars
   {
      set
      {
         environmentVars.Free();
         if(value)
         {
            delete environmentVars;
            environmentVars = value;
         }
      }
      get { return environmentVars; }
      isset { return environmentVars.count != 0; }
   }
   property Array<String> prepDirectives
   {
      set
      {
         prepDirectives.Free();
         if(value)
         {
            delete prepDirectives;
            prepDirectives = value;
         }
      }
      get { return prepDirectives; }
      isset { return prepDirectives.count != 0; }
   }
   property Array<String> excludeLibs
   {
      set
      {
         excludeLibs.Free();
         if(value)
         {
            delete excludeLibs;
            excludeLibs = value;
         }
      }
      get { return excludeLibs; }
      isset { return excludeLibs.count != 0; }
   }
   property Array<String> eCcompilerFlags
   {
      set
      {
         eCcompilerFlags.Free();
         if(value)
         {
            delete eCcompilerFlags;
            eCcompilerFlags = value;
         }
      }
      get { return eCcompilerFlags; }
      isset { return eCcompilerFlags.count != 0; }
   }
   property Array<String> compilerFlags
   {
      set
      {
         compilerFlags.Free();
         if(value)
         {
            delete compilerFlags;
            compilerFlags = value;
         }
      }
      get { return compilerFlags; }
      isset { return compilerFlags.count != 0; }
   }
   property Array<String> cxxFlags
   {
      set
      {
         cxxFlags.Free();
         if(value)
         {
            delete cxxFlags;
            cxxFlags = value;
         }
      }
      get { return cxxFlags; }
      isset { return cxxFlags.count != 0; }
   }
   property Array<String> linkerFlags
   {
      set
      {
         linkerFlags.Free();
         if(value)
         {
            delete linkerFlags;
            linkerFlags = value;
         }
      }
      get { return linkerFlags; }
      isset { return linkerFlags.count != 0; }
   }
   // json backward compatibility
   property const char * gccPrefix
   {
      set { delete gnuToolchainPrefix; if(value && value[0]) gnuToolchainPrefix = CopyString(value); }
      get { return gnuToolchainPrefix; }
      isset { return false; }
   }
   property const char * execPrefixCommand
   {
      set { delete executableLauncher; if(value && value[0]) executableLauncher = CopyString(value); }
      get { return executableLauncher; }
      isset { return false; }
   }
   property const char * outputFileExt
   {
      set { delete executableFileExt; if(value && value[0]) executableFileExt = CopyString(value); }
      get { return executableFileExt; }
      isset { return false; }
   }
   // utility
   property bool hasDocumentOutput
   {
      get
      {
         bool result = executableFileExt && executableFileExt[0] &&
               (!strcmpi(executableFileExt, "htm") || !strcmpi(executableFileExt, "html"));
         return result;
      }
      isset { return false; }
   }
private:
   Array<String> includeDirs { };
   Array<String> libraryDirs { };
   Array<String> executableDirs { };
   // TODO: Can JSON parse and serialize maps?
   //EnvironmentVariables { };
   Array<NamedString> environmentVars { };
   Array<String> prepDirectives { };
   Array<String> excludeLibs { };
   Array<String> eCcompilerFlags { };
   Array<String> compilerFlags { };
   Array<String> cxxFlags { };
   Array<String> linkerFlags { };
   char * name;
   char * makeCommand;
   char * ecpCommand;
   char * eccCommand;
   char * ecsCommand;
   char * earCommand;
   char * cppCommand;
   char * ccCommand;
   char * cxxCommand;
   char * ldCommand;
   char * arCommand;
   char * objectFileExt;
   char * staticLibFileExt;
   char * sharedLibFileExt;
   char * executableFileExt;
   char * executableLauncher;
   char * distccHosts;
   char * gnuToolchainPrefix;
   char * sysroot;

   ~CompilerConfig()
   {
      delete name;
      delete ecpCommand;
      delete eccCommand;
      delete ecsCommand;
      delete earCommand;
      delete cppCommand;
      delete ccCommand;
      delete cxxCommand;
      delete ldCommand;
      delete arCommand;
      delete objectFileExt;
      delete staticLibFileExt;
      delete sharedLibFileExt;
      delete executableFileExt;
      delete makeCommand;
      delete executableLauncher;
      delete distccHosts;
      delete gnuToolchainPrefix;
      delete sysroot;
      if(environmentVars) environmentVars.Free();
      if(includeDirs) { includeDirs.Free(); }
      if(libraryDirs) { libraryDirs.Free(); }
      if(executableDirs) { executableDirs.Free(); }
      if(prepDirectives) { prepDirectives.Free(); }
      if(excludeLibs) { excludeLibs.Free(); }
      if(compilerFlags) { compilerFlags.Free(); }
      if(cxxFlags) { cxxFlags.Free(); }
      if(eCcompilerFlags) { eCcompilerFlags.Free(); }
      if(linkerFlags) { linkerFlags.Free(); }
   }

   int OnCompare(CompilerConfig b)
   {
      int result;
      if(
         !(result = type.OnCompare(b.type)) &&
         !(result = targetPlatform.OnCompare(b.targetPlatform)) &&
         !(result = numJobs.OnCompare(b.numJobs)) &&
         !(result = ccacheEnabled.OnCompare(b.ccacheEnabled)) &&
         !(result = distccEnabled.OnCompare(b.distccEnabled)) &&
         !(result = resourcesDotEar.OnCompare(b.resourcesDotEar)) &&
         !(result = noStripTarget.OnCompare(b.noStripTarget))
         );

      if(!result &&
         !(result = name.OnCompare(b.name)) &&
         !(result = ecpCommand.OnCompare(b.ecpCommand)) &&
         !(result = eccCommand.OnCompare(b.eccCommand)) &&
         !(result = ecsCommand.OnCompare(b.ecsCommand)) &&
         !(result = earCommand.OnCompare(b.earCommand)) &&
         !(result = cppCommand.OnCompare(b.cppCommand)) &&
         !(result = ccCommand.OnCompare(b.ccCommand)) &&
         !(result = cxxCommand.OnCompare(b.cxxCommand)) &&
         !(result = ldCommand.OnCompare(b.ldCommand)) &&
         !(result = arCommand.OnCompare(b.arCommand)) &&
         !(result = objectFileExt.OnCompare(b.objectFileExt)) &&
         !(result = outputFileExt.OnCompare(b.outputFileExt)) &&
         !(result = makeCommand.OnCompare(b.makeCommand)) &&
         !(result = executableLauncher.OnCompare(b.executableLauncher)) &&
         !(result = distccHosts.OnCompare(b.distccHosts)) &&
         !(result = gnuToolchainPrefix.OnCompare(b.gnuToolchainPrefix)) &&
         !(result = sysroot.OnCompare(b.sysroot)));

      if(!result &&
         !(result = includeDirs.OnCompare(b.includeDirs)) &&
         !(result = libraryDirs.OnCompare(b.libraryDirs)) &&
         !(result = executableDirs.OnCompare(b.executableDirs)) &&
         !(result = environmentVars.OnCompare(b.environmentVars)) &&
         !(result = prepDirectives.OnCompare(b.prepDirectives)) &&
         !(result = excludeLibs.OnCompare(b.excludeLibs)) &&
         !(result = cxxFlags.OnCompare(b.cxxFlags)) &&
         !(result = eCcompilerFlags.OnCompare(b.eCcompilerFlags)) &&
         !(result = compilerFlags.OnCompare(b.compilerFlags)) &&
         !(result = linkerFlags.OnCompare(b.linkerFlags)));
      return result;
   }

public:
   CompilerConfig Copy()
   {
      CompilerConfig copy
      {
         name,
         readOnly,
         type,
         targetPlatform,
         numJobs,
         makeCommand,
         ecpCommand,
         eccCommand,
         ecsCommand,
         earCommand,
         cppCommand,
         ccCommand,
         cxxCommand,
         arCommand,
         ldCommand,
         objectFileExt,
         staticLibFileExt,
         sharedLibFileExt,
         executableFileExt,
         executableLauncher,
         ccacheEnabled,
         distccEnabled,
         false,
         distccHosts,
         gnuToolchainPrefix,
         sysroot,
         resourcesDotEar,
         noStripTarget
      };
      for(s : includeDirs) copy.includeDirs.Add(CopyString(s));
      for(s : libraryDirs) copy.libraryDirs.Add(CopyString(s));
      for(s : executableDirs) copy.executableDirs.Add(CopyString(s));
      for(ns : environmentVars) copy.environmentVars.Add(NamedString { name = ns.name, string = ns.string });
      for(s : prepDirectives) copy.prepDirectives.Add(CopyString(s));
      for(s : excludeLibs) copy.excludeLibs.Add(CopyString(s));
      for(s : compilerFlags) copy.compilerFlags.Add(CopyString(s));
      for(s : cxxFlags) copy.cxxFlags.Add(CopyString(s));
      for(s : eCcompilerFlags) copy.eCcompilerFlags.Add(CopyString(s));
      for(s : linkerFlags) copy.linkerFlags.Add(CopyString(s));

      incref copy;
      return copy;
   }

   CompilerConfig ::read(const char * path)
   {
      CompilerConfig d = null;
      readConfigFile(path, class(CompilerConfig), &d);
      return d;
   }

   void write(CompilerSettingsContainer settingsContainer)
   {
      char dir[MAX_LOCATION];
      char path[MAX_LOCATION];
      const char * settingsFilePath = settingsContainer.settingsFilePath;
      settingsContainer.getConfigFilePath(path, _class, dir, name);
      if(settingsFilePath && FileExists(settingsFilePath) && !FileExists(dir))
      {
         MakeDir(dir);
         if(!FileExists(dir))
            PrintLn($"Error creating compiler configs directory at ", dir, " location.");
      }
      writeConfigFile(path, _class, this);
   }
}

class CompilerConfigs : List<CompilerConfig>
{
   CompilerConfig GetCompilerConfig(const String compilerName)
   {
      const char * name = compilerName && compilerName[0] ? compilerName : defaultCompilerName;
      CompilerConfig compilerConfig = null;
      for(compiler : this)
      {
         if(!strcmp(compiler.name, name))
         {
            compilerConfig = compiler;
            break;
         }
      }
      if(!compilerConfig && count)
         compilerConfig = this[0];
      if(compilerConfig)
      {
         incref compilerConfig;
         if(compilerConfig._refCount == 1)
            incref compilerConfig;
      }
      return compilerConfig;
   }

   void ensureDefaults()
   {
      // Ensure we have a default compiler
      CompilerConfig defaultCompiler = GetCompilerConfig(defaultCompilerName);
      if(!defaultCompiler)
      {
         defaultCompiler = MakeDefaultCompiler(defaultCompilerName, true);
         Insert(null, defaultCompiler);
         defaultCompiler = null;
      }
      delete defaultCompiler;

      for(ccfg : this)
      {
         if(!ccfg.ecpCommand || !ccfg.ecpCommand[0])
            ccfg.ecpCommand = ecpDefaultCommand;
         if(!ccfg.eccCommand || !ccfg.eccCommand[0])
            ccfg.eccCommand = eccDefaultCommand;
         if(!ccfg.ecsCommand || !ccfg.ecsCommand[0])
            ccfg.ecsCommand = ecsDefaultCommand;
         if(!ccfg.earCommand || !ccfg.earCommand[0])
            ccfg.earCommand = earDefaultCommand;
         if(!ccfg.cppCommand || !ccfg.cppCommand[0])
            ccfg.cppCommand = cppDefaultCommand;
         if(!ccfg.ccCommand || !ccfg.ccCommand[0])
            ccfg.ccCommand = ccDefaultCommand;
         if(!ccfg.cxxCommand || !ccfg.cxxCommand[0])
            ccfg.cxxCommand = cxxDefaultCommand;
         /*if(!ccfg.ldCommand || !ccfg.ldCommand[0])
            ccfg.ldCommand = ldDefaultCommand;*/
         if(!ccfg.arCommand || !ccfg.arCommand[0])
            ccfg.arCommand = arDefaultCommand;
         if(!ccfg.objectFileExt || !ccfg.objectFileExt[0])
            ccfg.objectFileExt = objectDefaultFileExt;
         /*if(!ccfg.staticLibFileExt || !ccfg.staticLibFileExt[0])
            ccfg.staticLibFileExt = staticLibDefaultFileExt;*/
         /*if(!ccfg.sharedLibFileExt || !ccfg.sharedLibFileExt[0])
            ccfg.sharedLibFileExt = sharedLibDefaultFileExt;*/
         /*if(!ccfg.executableFileExt || !ccfg.executableFileExt[0])
            ccfg.executableFileExt = outputDefaultFileExt;*/
         if(!ccfg._refCount) incref ccfg;
      }
   }

   AVLTree<String> getWriteRequiredList(CompilerConfigs oldConfigs)
   {
      AVLTree<String> list { };
      for(ccfg : this)
      {
         bool found = false;
         for(occfg : oldConfigs; !strcmp(ccfg.name, occfg.name))
         {
            found = true;
            if(ccfg.OnCompare(occfg))
               list.Add(CopyString(ccfg.name));
            break;
         }
         if(!found)
            list.Add(CopyString(ccfg.name));
      }
      return list;
   }

   bool read(CompilerSettingsContainer settingsContainer)
   {
      if(settingsContainer.settingsFilePath)
      {
         char dir[MAX_LOCATION];
         char path[MAX_LOCATION];
         Class _class = class(CompilerConfig);
         settingsContainer.getConfigFilePath(path, _class, dir, null);
         if(dir[0])
         {
            AVLTree<const String> addedConfigs { };
            Map<String, CompilerConfig> compilerConfigsByName = getCompilerConfigsByName(dir);
            MapIterator<const String, CompilerConfig> it { map = compilerConfigsByName };
            Free();
            settingsContainer.compilerConfigs = this; // Merge CompilerConfigHolder / CompilerSettingsContainer?
            if(it.Index("Default", false))
            {
               CompilerConfig ccfg = it.data;
               Add(ccfg.Copy());
               addedConfigs.Add(ccfg.name);
            }
            for(ccfg : compilerConfigsByName)
            {
               if(!addedConfigs.Find(ccfg.name))
               {
                  Add(ccfg.Copy());
                  addedConfigs.Add(ccfg.name);
               }
            }
            addedConfigs.Free();
            delete addedConfigs;
            ensureDefaults();
            compilerConfigsByName.Free();
            delete compilerConfigsByName;
            settingsContainer.onLoadCompilerConfigs();
            return true;
         }
      }
      return false;
   }

   void write(CompilerSettingsContainer settingsContainer, AVLTree<String> cfgsToWrite)
   {
      char dir[MAX_LOCATION];
      char path[MAX_LOCATION];
      Map<String, String> paths;
      settingsContainer.getConfigFilePath(path, class(CompilerConfig), dir, null);
      paths = getCompilerConfigFilePathsByName(dir);
      {
         MapIterator<String, String> it { map = paths };
         for(c : this)
         {
            CompilerConfig ccfg = c;
            if(!cfgsToWrite || cfgsToWrite.Find(ccfg.name))
               ccfg.write(settingsContainer);
            if(it.Index(ccfg.name, false))
            {
               delete it.data;
               it.Remove();
            }
         }
      }
      for(p : paths)
      {
         const char * path = p;
         DeleteFile(path);
      }
      paths.Free();
      delete paths;
   }
}


static Map<String, String> getCompilerConfigFilePathsByName(const char * path)
{
   Map<String, String> map { };
   FileListing fl { path, extensions = "econ" };
   while(fl.Find())
   {
      if(fl.stats.attribs.isFile)
      {
         char name[MAX_FILENAME];
         char * path = CopyString(fl.path);
         MakeSlashPath(path);
         GetLastDirectory(path, name);
         StripExtension(name);
         map[name] = path;
      }
   }
   return map;
}

static Map<String, CompilerConfig> getCompilerConfigsByName(const char * path)
{
   Map<String, CompilerConfig> map { };
   FileListing fl { path, extensions = "econ" };
   while(fl.Find())
   {
      if(fl.stats.attribs.isFile)
      {
         char name[MAX_FILENAME];
         char * path = CopyString(fl.path);
         MakeSlashPath(path);
         GetLastDirectory(path, name);
         StripExtension(name);
         {
            CompilerConfig ccfg = CompilerConfig::read(path);
            if(ccfg)
               map[name] = ccfg;
         }
         delete path;
      }
   }
   return map;
}

CompilerConfig MakeDefaultCompiler(const char * name, bool readOnly)
{
   CompilerConfig defaultCompiler
   {
      name,
      readOnly,
      gcc,
      __runtimePlatform,
      1,
      makeDefaultCommand,
      ecpDefaultCommand,
      eccDefaultCommand,
      ecsDefaultCommand,
      earDefaultCommand,
      cppDefaultCommand,
      ccDefaultCommand,
      cxxDefaultCommand,
      arDefaultCommand
      //ldDefaultCommand
   };
   incref defaultCompiler;
   return defaultCompiler;
}

char * CopyValidateMakefilePath(const char * path)
{
   const int map[]  =    {           0,           1,             2,             3,           4,                    5,                 6,            0,                   1,                    2,        7 };
   const char * vars[] = { "$(MODULE)", "$(CONFIG)", "$(PLATFORM)", "$(COMPILER)", "$(TARGET)", "$(COMPILER_SUFFIX)", "$(DEBUG_SUFFIX)", "$(PROJECT)",  "$(CONFIGURATION)", "$(TARGET_PLATFORM)",(char *)0 };

   char * copy = null;
   if(path)
   {
      int len;
      len = (int)strlen(path);
      copy = CopyString(path);
      if(len)
      {
         int c;
         char * tmp = copy;
         char * start = tmp;
         Array<const char *> parts { };

         for(c=0; c<len; c++)
         {
            if(tmp[c] == '$')
            {
               int v;
               for(v=0; vars[v]; v++)
               {
                  if(SearchString(&tmp[c], 0, vars[v], false, false) == &tmp[c])
                  {
                     tmp[c] = '\0';
                     parts.Add(start);
                     parts.Add(vars[map[v]]);
                     c += strlen(vars[v]);
                     start = &tmp[c];
                     c--;
                     break;
                  }
               }
            }
         }
         if(start[0])
            parts.Add(start);

         if(parts.count)
         {
            /*int c, */len = 0;
            for(c=0; c<parts.count; c++) len += strlen(parts[c]);
            copy = new char[++len];
            copy[0] = '\0';
            for(c=0; c<parts.count; c++) strcat(copy, parts[c]);
         }
         else
            copy = null;
         delete parts;
         delete tmp;
      }
   }
   return copy;
}
