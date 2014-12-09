using System;

class text01
{
    public static void Main(string[] args)
    {
        string str = "";

        // argsの長さだけ出力。
        // argsの長さはargs.Lengthで取得する。
        for (int i = 0; i < args.Length; i++)
        {
            int m = args[i].Length;
            for (int j = 0; j < m; j++)
            {
                str += args[i].Substring(m-j-1,1);
            }
        }


        string html = "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'><title>CGI page</title></head><body>";

        html += str;

        html += "</body></html>";

        Console.WriteLine(html);


    }
}

