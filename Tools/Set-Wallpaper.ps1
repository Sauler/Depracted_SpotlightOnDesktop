Param
(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$file
)

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    using Microsoft.Win32;
    namespace SpotlightOnDesktop
    {
        public enum Style : int
        {
            Tiled,
            Centered,
            Stretched
        }

        public class Wallpaper {
            const int SPI_SETDESKWALLPAPER = 20;
            const int SPIF_UPDATEINIFILE = 0x01;
            const int SPIF_SENDWININICHANGE = 0x02;
            [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
            private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);

            public static void Set (string path, SpotlightOnDesktop.Style style)
            {
                SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);

                RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
                switch(style)
                {
                    case Style.Stretched:
                        key.SetValue(@"WallpaperStyle", "2") ; 
                        key.SetValue(@"TileWallpaper", "0") ;
                        break;
                    case Style.Centered:
                        key.SetValue(@"WallpaperStyle", "1") ; 
                        key.SetValue(@"TileWallpaper", "0") ; 
                        break;
                    case Style.Tiled:
                        key.SetValue(@"WallpaperStyle", "1") ; 
                        key.SetValue(@"TileWallpaper", "1") ;
                        break;
                }
                key.Close();
            }
        }
    }
"@

[SpotlightOnDesktop.Wallpaper]::Set($file, 2)
