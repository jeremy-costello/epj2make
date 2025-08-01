#ifdef EC_STATIC
public import static "ecrt"
#else
public import "ecrt"
#endif

import "Project"
import "CompilerSettings"

#if defined(__WIN32__)
define pathListSep = ";";
#else
define pathListSep = ":";
#endif

#if defined(_DEBUG) && defined(__WIN32__)
extern int getch(void);
#endif

CompilerSettingsContainer settingsContainer { };
CompilerConfigHolder compilerConfig { };

void ParseDirList(char * string, Container<String> list)
{
   int c;
   char * tokens[256];
   printf("DEBUG: Parsing directory list: %s\n", string);
   int numTokens = TokenizeWith(string, sizeof(tokens) / sizeof(byte *), tokens, ";", false);
   list.Free();
   for(c = 0; c < numTokens; c++) {
      printf("DEBUG: Adding directory: %s\n", tokens[c]);
      list.Add(CopyString(tokens[c]));
   }
}

class epj2makeApp : Application
{
   void Main()
   {
      printf("DEBUG: Entering Main()\n");

      int c;
      bool valid = true;
      char * configName = null;
      char * epjPath = null;
      char * makePath = null;

      Project project = null;
      CompilerConfig optionsCompiler { };

      bool noGlobalSettings = false;
      bool noResources = false;
      bool noWarnings = false;
      const char * overrideObjDir = null;
      const char * includemkPath = null;

      printf("DEBUG: Starting argument parsing\n");

      for(c = 1; c < argc; c++)
      {
         const char * arg = argv[c];
         printf("DEBUG: Parsing arg[%d]: %s\n", c, arg);
         if(arg[0] == '-')
         {
            if(!strcmpi(arg+1, "compiler-config"))
            {
               if(++c < argc)
               {
                  const String path = argv[c];
                  printf("DEBUG: --compiler-config = %s\n", path);
                  delete optionsCompiler;
                  if(FileExists(path))
                     optionsCompiler = CompilerConfig::read(path);
                  else
                     printf("Error: Project compiler configuration file (%s) was not found.\n", path);
               }
               else valid = false;
            }
            else if(!strcmpi(arg+1, "make")) {
               if(++c < argc) optionsCompiler.makeCommand = argv[c];
               else valid = false;
            }
            else if(!strcmpi(arg+1, "cpp")) {
               if(++c < argc) optionsCompiler.cppCommand = argv[c];
               else valid = false;
            }
            else if(!strcmpi(arg+1, "cc")) {
               if(++c < argc) optionsCompiler.ccCommand = argv[c];
               else valid = false;
            }
            else if(!strcmpi(arg+1, "ecp")) {
               if(++c < argc) optionsCompiler.ecpCommand = argv[c];
               else valid = false;
            }
            else if(!strcmpi(arg+1, "ecc")) {
               if(++c < argc) optionsCompiler.eccCommand = argv[c];
               else valid = false;
            }
            else if(!strcmpi(arg+1, "ecs")) {
               if(++c < argc) optionsCompiler.ecsCommand = argv[c];
               else valid = false;
            }
            else if(!strcmpi(arg+1, "ear")) {
               if(++c < argc) optionsCompiler.earCommand = argv[c];
               else valid = false;
            }
            else if(!strcmpi(arg+1, "noglobalsettings")) {
               noGlobalSettings = true;
            }
            else if(!strcmpi(arg+1, "noresources")) {
               noResources = true;
            }
            else if(!strcmpi(arg+1, "includemk")) {
               if(++c < argc) includemkPath = argv[c];
               else valid = false;
            }
            else if(arg[1] == 'w' && !arg[2]) {
               noWarnings = true;
            }
            else if(arg[1] == 'c' && !arg[2]) {
               if(++c < argc) {
                  int argLen = strlen(argv[c]);
                  configName = new char[argLen + 1];
                  strcpy(configName, argv[c]);
               } else valid = false;
            }
            else if(arg[1] == 't' && !arg[2]) {
               if(++c < argc); else valid = false;
            }
            else if(arg[1] == 'o') {
               if(++c < argc) {
                  int argLen = strlen(argv[c]);
                  makePath = new char[argLen + 1];
                  strcpy(makePath, argv[c]);
               } else valid = false;
            }
            else if(arg[1] == 'i') {
               if(++c < argc)
                  ParseDirList((char *)argv[c], optionsCompiler.includeDirs);
               else valid = false;
            }
            else if(arg[1] == 'l') {
               if(++c < argc)
                  ParseDirList((char *)argv[c], optionsCompiler.libraryDirs);
               else valid = false;
            }
            else if(arg[1] == 'd' && !arg[2]) {
               if(++c < argc) overrideObjDir = argv[c];
               else valid = false;
            }
            else {
               valid = false;
               printf("DEBUG: Invalid option: %s\n", arg);
            }
         }
         else {
            if(!epjPath) {
               int argLen = strlen(arg);
               epjPath = new char[argLen + 1];
               strcpy(epjPath, arg);
               printf("DEBUG: Set epjPath = %s\n", epjPath);
               c++;
            } else {
               valid = false;
               printf("DEBUG: Unexpected argument: %s\n", arg);
            }
         }
      }

      if(!epjPath) {
         valid = false;
         printf("DEBUG: No epjPath provided\n");
      }

      if(!valid)
      {
         printf("DEBUG: Invalid input, printing usage\n");
         printf("Syntax:\n");
         printf("   epj2make [options] <input>\n");
         printf("   Use -compiler-config, -make, -cpp, -cc, -ecp, -ecc, -ecs, -ear, -i, -l, -d, -includemk\n");
      }
      else
      {
         if(FileExists(epjPath).isFile)
         {
            char extension[MAX_EXTENSION] = "";
            GetExtension(epjPath, extension);
            strlwr(extension);
            printf("DEBUG: Project file extension = %s\n", extension);

            if(!strcmp(extension, ProjectExtension))
            {
               if(noGlobalSettings)
               if(noGlobalSettings)
            {
               printf("DEBUG 1: noGlobalSettings is true, using default compiler\n");
               defaultCompiler = MakeDefaultCompiler("Default", true);
            }
            else
            {
               printf("DEBUG 2: noGlobalSettings is false, attempting to load global compiler settings\n");

               const char * compiler = getenv("COMPILER");
               printf("DEBUG 3: getenv(\"COMPILER\") returned: %s\n", compiler ? compiler : "(null)");
               if(!compiler) compiler = "Default";

               printf("DEBUG 4: Calling settingsContainer.Load()\n");
               settingsContainer.Load();
               printf("DEBUG 5: settingsContainer.Load() completed\n");

               printf("DEBUG 6: Reading compilers from settingsContainer\n");
               compilerConfig.compilers.read(settingsContainer);
               printf("DEBUG 7: compilers read successfully\n");

               delete settingsContainer;
               printf("DEBUG 8: settingsContainer deleted\n");

               printf("DEBUG 9: Getting compiler config for: %s\n", compiler);
               defaultCompiler = compilerConfig.compilers.GetCompilerConfig(compiler);
               printf("DEBUG 10: defaultCompiler = %p\n", defaultCompiler);
            }

               if(optionsCompiler.makeCommand) defaultCompiler.makeCommand = optionsCompiler.makeCommand;
               if(optionsCompiler.cppCommand) defaultCompiler.cppCommand = optionsCompiler.cppCommand;
               if(optionsCompiler.ccCommand) defaultCompiler.ccCommand = optionsCompiler.ccCommand;
               if(optionsCompiler.ecpCommand) defaultCompiler.ecpCommand = optionsCompiler.ecpCommand;
               if(optionsCompiler.eccCommand) defaultCompiler.eccCommand = optionsCompiler.eccCommand;
               if(optionsCompiler.ecsCommand) defaultCompiler.ecsCommand = optionsCompiler.ecsCommand;
               if(optionsCompiler.earCommand) defaultCompiler.earCommand = optionsCompiler.earCommand;

               for(dir : optionsCompiler.includeDirs)
                  defaultCompiler.includeDirs.Add(CopyString(dir));
               for(dir : optionsCompiler.libraryDirs)
                  defaultCompiler.libraryDirs.Add(CopyString(dir));

               delete optionsCompiler;

               printf("DEBUG: Loading project: %s\n", epjPath);
               project = LoadProject(epjPath, null);
               if(project)
               {
                  printf("DEBUG: Project loaded\n");
                  ProjectConfig defaultConfig = null;

                  if(configName)
                  {
                     printf("DEBUG: Searching for config: %s\n", configName);
                     valid = false;
                     for(config : project.configurations)
                     {
                        if(!strcmpi(configName, config.name))
                        {
                           project.config = config;
                           valid = true;
                           break;
                        }
                     }
                     if(!valid)
                        printf("Error: Project configuration (%s) was not found.\n", configName);
                  }
                  else
                  {
                     printf("DEBUG: No config name provided, trying 'Release'\n");
                     ProjectConfig releaseConfig = null;
                     for(config : project.configurations)
                     {
                        if(!strcmpi(config.name, "Release"))
                        {
                           releaseConfig = config;
                           break;
                        }
                     }
                     if(!releaseConfig && project.configurations.count)
                     {
                        releaseConfig = project.configurations[0];
                        printf("Notice: Project configuration (%s) will be used.\n", releaseConfig.name);
                     }

                     if(releaseConfig)
                     {
                        project.config = releaseConfig;
                        if(overrideObjDir)
                        {
                           printf("DEBUG: Overriding object dir = %s\n", overrideObjDir);
                           delete releaseConfig.options.targetDirectory;
                           delete releaseConfig.options.objectsDirectory;
                           releaseConfig.options.targetDirectory = CopyString(overrideObjDir);
                           releaseConfig.options.objectsDirectory = CopyString(overrideObjDir);
                        }
                        if(noWarnings)
                           releaseConfig.options.warnings = none;
                     }
                     else if(overrideObjDir)
                     {
                        delete project.options.targetDirectory;
                        project.options.targetDirectory = CopyString(overrideObjDir);
                        delete project.options.objectsDirectory;
                        project.options.objectsDirectory = CopyString(overrideObjDir);
                     }
                     if(noWarnings)
                        project.options.warnings = none;
                  }

                  if(valid && defaultCompiler)
                  {
                     printf("DEBUG: Generating compiler config and makefile\n");
                     bool hasEcFiles = project.topNode.ContainsFilesWithExtension("ec", project.config);
                     project.GenerateCompilerCf(defaultCompiler, hasEcFiles);
                     project.GenerateCrossPlatformMk(null);

                     if(project.GenerateMakefile(makePath, noResources, includemkPath, project.config))
                     {
                        printf("DEBUG: Makefile generated successfully\n");
                        if(makePath) printf("%s\n", makePath);
                     }
                     else
                     {
                        printf("DEBUG: Failed to generate makefile\n");
                     }
                  }

                  if(noGlobalSettings)
                     delete defaultCompiler;

                  delete defaultConfig;
                  delete project;
               }
               else
               {
                  printf("ERROR: Unable to open project file (%s)\n", epjPath);
               }
            }
         }
         else
         {
            printf("ERROR: File does not exist: %s\n", epjPath);
         }
      }

      printf("DEBUG: Cleaning up\n");
      delete optionsCompiler;
      delete configName;
      delete epjPath;
      delete makePath;
      delete defaultCompiler;

#if defined(_DEBUG) && defined(__WIN32__)
      getch();
#endif

      printf("DEBUG: Exiting Main()\n");
   }
}
