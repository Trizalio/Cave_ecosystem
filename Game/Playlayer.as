package Game
{
	import Game.Map;
    import flash.display.MovieClip;
	import flash.events.Event; 
    public class Playlayer extends MovieClip
    {
		private var m_Map:Game.Map;
		private var m_FramesSkipped:int = 0;
        public function Playlayer()
        {
			trace("Playlayer");
			m_Map = new Game.Map();
			this.addChild(m_Map);
			trace("!Playlayer");
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
		public function onEnterFrame(event:Event)
		{
			m_Map.generationTickPreDivider();
			++m_FramesSkipped;
			if(m_FramesSkipped > 10)
			{
				m_FramesSkipped = 0;
			}
		}
    }
}