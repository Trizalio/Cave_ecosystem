package Game
{
	import Game.Map;
    import flash.display.MovieClip;
	import flash.events.Event; 
    public class Playlayer extends MovieClip
    {
		private var m_Map:Game.Map;
		private var m_FramesSkipped:int = 0;
		private var m_MapGenerated:Boolean = false;
        public function Playlayer()
        {
			trace("Playlayer");
			m_Map = new Game.Map();
			this.addChild(m_Map);
			m_Map.x = 0;
			m_Map.y = 0;
			trace("!Playlayer");
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
		public function onEnterFrame(event:Event)
		{
			if(!m_MapGenerated)
			{
				m_MapGenerated = m_Map.generationTick();
			}
		}
    }
}