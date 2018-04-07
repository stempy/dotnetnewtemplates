using System;
using System.IO;

namespace AsmRename
{
    class Program
    {
        static void Main(string[] args)
        {
            var path = args[0];
            var filespec = args[1];
            var searchStr = args[2];
            var replStr = args[3];
            
            //     namespace Db.CONTEXT_NAME.Context.CONTEXT_NAME
            // --> namespace Db.CONTEXT_NAME.Context
            // --> namespace Db.CONTEXT_NAME.Models
            
            var files = Directory.GetFiles(path,filespec,SearchOption.TopDirectoryOnly);
            foreach(var f in files){
                var cnt = File.ReadAllText(f);
                replStr = replStr.Replace(@"\n",Environment.NewLine);
                cnt = cnt.Replace(searchStr,replStr);
                File.WriteAllText(f,cnt);
                var filename = Path.GetFileName(f);
                Console.WriteLine($"{filename}: {searchStr} => {replStr}");
            }

            Console.WriteLine("Completed!.");
        }
    }
}
