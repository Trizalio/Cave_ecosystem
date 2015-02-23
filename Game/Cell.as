package Game
{
    public class Cell
    {
		public static var c_DurabilityMax:Number = 10;
		public var m_Durability:Number;
		public var m_WaterLevel:Number;
		
		public var m_Illumination:Number;
		
		public var m_Wall:Boolean;
		public var m_Inner:Boolean;
		
		public var m_Damaged:Boolean;
		
		public var m_X:Number;
		public var m_Y:Number;
		
		public var m_NeighborTop:Cell;
		public var m_NeighborLeft:Cell;
		public var m_NeighborBottom:Cell;
		public var m_NeighborRight:Cell;
		
		public var m_DamageResistance:Number;
		
		private var m_Neighbors:Array = new Array(3); 
		private function initArray():void
		{
			for(var i:int = 0; i < 3; ++i)
			{
				m_Neighbors[i] = new Array(3);
			}
		}
		public function setNeighbor(i, j, Neighbor):void
		{
			if(i >= -1 && i <= 1 && j >= -1 && j <= 1)
			{
				m_Neighbors[i][j] = Neighbor;
			}
		}
		public function getNeighbor(i, j):Cell
		{
			if(i >= -1 && i <= 1 && j >= -1 && j <= 1)
			{
				return m_Neighbors[i][j];
			}
			return null;
		}
		
		public function Cell(MyX, MyY)
		{
			//trace("Cell");
			initArray();
			m_X = MyX;
			m_Y = MyY;
			m_Wall = true;
			m_Inner = true;
			m_Illumination = 0.5;
			m_WaterLevel = 0;
			m_Durability = Math.random()*c_DurabilityMax;
			m_Damaged = false;
			m_DamageResistance = 0;
			
			//trace("!Cell");
		}
		
		public function takeDirectDamage(Damage:Number):Boolean
		{
			m_Damaged = true;
			if(!m_Wall){return true;}
			m_Durability -= Damage;
			if(m_Durability <= 0)
			{
				m_Durability = 0;
				breakWall();
				return true;
			}
			return false;
		}
		
		
		/*public function calculateDamageResistance():void
		{
			var NeighborsAbsorption = 0;
			for(var i:int = -1; i <= 0; ++i)
			{
				for(var j:int = -1; j < 2; ++j)
				{
					if(i == 0 && j == 0)
					{
						break;
					}
					var CurNeighbor1:Cell = getNeighbor(i, j);
					var CurNeighbor2:Cell = getNeighbor(i, j);
					if(CurNeighbor)
					{
						if(CurNeighbor.isWall())
						{
							
						}
					}
				}
			}
			m_DamageResistance = ;
		}*/
		
		public function isDamaged():Boolean
		{
			return m_Damaged;
		}
		public function takeDamage(Damage:Number, Sharpness:Number):Boolean
		{
			return takeDirectDamage(Damage);
		}
		public function isWall():Boolean
		{
			return m_Wall;
		}
		public function isInner():Boolean
		{
			return m_Inner;
		}
		public function breakWall():void
		{
			m_Wall = false;
			if(m_Inner)
			{
				return;
			}
			if(m_NeighborTop)
			{
				m_NeighborTop.m_Inner = false;
			}
			if(m_NeighborLeft)
			{
				m_NeighborLeft.m_Inner = false;
			}
			if(m_NeighborBottom)
			{
				m_NeighborBottom.m_Inner = false;
			}
			if(m_NeighborRight)
			{
				m_NeighborRight.m_Inner = false;
			}
		}
		public function makeOuter():void
		{
			m_Inner = false;
		}
		public function makeInner():void
		{
			m_Inner = true;
		}
    }
}