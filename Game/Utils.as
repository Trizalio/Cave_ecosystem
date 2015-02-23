package Game
{
    public class Utils
    {
		public function Utils()
		{
		}
		public static function getColorbyRGB(Red, Green, Blue):uint
		{
			return (Red << 16) + (Green << 8) + (Blue);
		}
    }
}