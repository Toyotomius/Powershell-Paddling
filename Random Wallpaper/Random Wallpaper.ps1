#
# Random Wallpaper - Creates a random image using a Bezier drawing and applies it as a wallpaper on Windows based OS.
#
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

while($true)
{
	$random = New-Object System.Random
	# Errors if the folder doesn't exist. Set to current user's picture folder.
	[string]$fileName = [Environment]::GetFolderPath("MyPictures") + "\RandomImage.jpg"

	# Create and apply properties for the image to be created.
    $height = 1080
    $width = 1920
    $backgroundColor = [System.Drawing.Color]::Black
    $image = New-Object System.Drawing.Bitmap($width, $height)
    [System.Drawing.Graphics]::FromImage($image).FillRectangle((New-Object System.Drawing.SolidBrush($backgroundColor)), 0, 0, $width, $height)

    $graphics = [System.Drawing.Graphics]::FromImage($image)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

	# Bezier requires a start, two center points and an end to create the curve for this drawing.
	# Adjust accordingly for other drawing styles.

    $start = New-Object System.Drawing.Point
    $centerPoint1 = New-Object System.Drawing.Point
    $centerPoint2 = New-Object System.Drawing.Point
    $end = New-Object System.Drawing.Point

	# Creates the vertices randomly, a random number of times, drawing each one with a random pen of a random color.
    for ($i = 1; $i -lt $random.Next(2,100); $i++)
    {
        $start.X = $random.Next(0, $width)
        $centerPoint1.X = $random.Next(0, $width)
        $centerPoint2.X = $random.Next(0, $width)
        $end.X = $random.Next(0, $width)

        $start.Y = $random.Next(0, $height)
        $centerPoint1.Y = $random.Next(0, $height)
        $centerPoint2.Y = $random.Next(0, $height)
        $end.Y = $random.Next(0, $height)

        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($random.Next(0, 255), $random.Next(0, 255), $random.Next(0, 255)), $random.Next(5,50))
        $graphics.DrawBezier($pen, $start, $centerPoint1, $centerPoint2, $end)
    }

     # Attempts to create and save the new drawing as a jpeg.
     try
     {
        $qualityParam = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 100)
        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |Where-Object {$_.MimeType -eq "image/jpeg"}
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)-Property @{Param = $qualityParam}
		# Small sleep added to compensate for duplicate files being created sequentially on occassion. 
		# May need to be adjusted. I have not tested on alternative systems. An alternative would be for another try inside the catch
		# but that's ugly and not ideal.
		Start-Sleep -Milliseconds 20 
        $image.Save($fileName, $jpegCodec, $encoderParams);
     }
     catch [Exception]
     {
        $_.Exception.ToString()
     }

	# Uncomment these if you want to apply a random file as the wallpaper instead. Replace $fileName from above with $files in below Set-ItemProperty
    #$path = "C:\Test\Test"
    #$files = Get-ChildItem -Path $path
    #$wallpaper = $files | Get-Random

    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $fileName
    
    $setwallpapersource = @"
    using System.Runtime.InteropServices;
    public class wallpaper
    {
        public const int SetDesktopWallpaper = 20;
        public const int UpdateIniFile = 0x01;
        public const int SendWinIniChange = 0x02;
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
        public static void SetWallpaper ( string path )
        {
            SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
        }
    }
"@
    Add-Type -TypeDefinition $setwallpapersource
	# Replace $fileName with $wallpaper.FullName if switching to randomly picking files.
    [wallpaper]::SetWallpaper($fileName)
	# The random sleep here is purely for trolling purposes. Switch that out for whatever you want.
    Start-Sleep -Seconds $random.Next(5, 60)
}