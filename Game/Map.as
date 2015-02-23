package Game
{
	import Game.Cell;
	import Game.Utils;
    import flash.display.MovieClip;
    public class Map extends MovieClip
    {
		// Constants
		private static var c_CellSize:int = 10;
		private static var c_MapSize:int = 200;
		private static var c_MountainRandomFactor:int = c_MapSize/40;

		
		// Outer charasteristics
		private var m_Scale:Number = 100/c_MapSize;
		
		private var m_Drawlayer:flash.display.MovieClip;
		private var m_MapData:Array = new Array(c_MapSize); 
		
		private var m_GenerationStep:int = 0;
		private var m_NextSourceX:int = 0;
		private var m_NextSourceY:int = 0;
		
		private var m_TicksSkipped:int = 0;
		
		private var m_ReachableCells:Array = new Array();
		private var m_DamagedCells:Array = new Array();
		private var m_ConnectedToOuter:Boolean = true;
		
		///////////////////////////////////////////////////////////////////////////////////
        public function Map()
        {
            trace("Map");
			generateArray();
			m_GenerationStep = 1;
			//generateMountain();
			//createCave();
			//checkReachability();
			renderMap();
            trace("!Map");
        }
		///////////////////////////////////////////////////////////////////////////////////
		public function generationTickPreDivider()
		{
			if(++m_TicksSkipped > 2)
			{
				m_TicksSkipped = 0;
				generationTick();
			}
//			destroyTick()
		}
		///////////////////////////////////////////////////////////////////////////////////
		private var m_tmpHolder:int = 0;
		private function generationTick()
		{
            trace("generationStep " + m_GenerationStep);
			if(m_GenerationStep == 1)
			{
				generateMountain();
				m_GenerationStep = 2;
			}
			else if(m_GenerationStep == 2)
			{
				if(m_ConnectedToOuter || m_DamagedCells.length > c_MapSize*c_MapSize/1)
				{
					if(createNextSource())
					{
						m_GenerationStep = 3;
					}
				} 
				else 
				{
					destroyTick();
				}
				if(++m_tmpHolder > 20)
				{
					m_tmpHolder = 0;
					renderMap();
				}
			}
			else if(m_GenerationStep == 3)
			{
				checkReachability();
				m_GenerationStep = 4;
			}
			
			if(m_GenerationStep != 2)
			{
				renderMap();
			}
            trace("!generationStep");
		}
//		public function 
		///////////////////////////////////////////////////////////////////////////////////
        public function createNextSource():Boolean
        {
            trace("createNextSource");
			var Divider:uint = c_MapSize/20;
			var Step:uint = (c_MapSize-1)/Divider;
			while(true)
			{
				if(m_NextSourceX < c_MapSize)
				{
					m_NextSourceY += Step;
					if(m_NextSourceY > c_MapSize)
					{
						m_NextSourceY = 0;
						m_NextSourceX += Step;
						if(m_NextSourceX > c_MapSize)
						{
							trace("!createNextSource");
							return true;
						}
					}
					trace("here?");
					trace(m_NextSourceX + ", " + m_NextSourceY);
					if(m_MapData[m_NextSourceX][m_NextSourceY].isWall())
					{
						trace("here!");
						m_ReachableCells.length = 0;
						m_DamagedCells.length = 0;
						m_ReachableCells.push(m_MapData[m_NextSourceX][m_NextSourceY]);
						m_DamagedCells.push(m_MapData[m_NextSourceX][m_NextSourceY]);
						m_ConnectedToOuter = false;
						//createNewSource(m_MapData[m_NextSourceX][m_NextSourceY]);
						//renderMap();
						return false;
					}
					trace("!createNextSource");
				}
			}
			return true;
        }
		
		
		///////////////////////////////////////////////////////////////////////////////////
		
		private function destroyTick():void
		{
			trace("destroyTick");
			//for(var i:int = 0; i < c_MapSize*c_MapSize/50 || !m_ConnectedToOuter; ++i)
			//{
            	//trace("looking for target");
				var MinDurability = Cell.c_DurabilityMax;
				var TargetCellNumber:int = -1;
				for(var j:int = 0; j < m_ReachableCells.length; ++j)
				{
					var CurCell:Cell = m_ReachableCells[j];
					if(MinDurability > CurCell.m_Durability)
					{
						if(CurCell.m_Durability <= 0)
						{
							var CurNeighbor0:Cell;
							for(var s:int = 0; s < 4; ++s)
							{
								if(s == 0)
								{
									CurNeighbor0 = CurCell.m_NeighborLeft;
								}
								else if(s == 1)
								{
									CurNeighbor0 = CurCell.m_NeighborRight;
								}
								else if(s == 2)
								{
									CurNeighbor0 = CurCell.m_NeighborTop;
								}
								else if(s == 3)
								{
									CurNeighbor0 = CurCell.m_NeighborBottom;
								}
								if(CurNeighbor0)
								{
									if(m_ReachableCells.indexOf(CurNeighbor0) < 0 && m_DamagedCells.indexOf(CurNeighbor0) < 0)
									{
										m_ReachableCells.push(CurNeighbor0);
										m_DamagedCells.push(CurNeighbor0);
									}
								}
							}
							if(!CurCell.isInner())
							{
								m_ConnectedToOuter = true;
							}
							m_ReachableCells.splice(j, 1);
							--j;
							
						}
						else
						{
							MinDurability = CurCell.m_Durability;
							TargetCellNumber = j;
						}
					}
				}
				
            	//trace("checking target");
				if(TargetCellNumber >= 0)
				{
            		//trace("target found");
					var TargetCell:Cell = m_ReachableCells[TargetCellNumber];
					var Damage:Number = TargetCell.m_Durability;
					var SideDamage:Number = Damage/4;
					var CurNeighbor:Cell;
					var NeighborsDamaged:int = 0;
					TargetCell.takeDamage(Damage, 0);
					for(var k:int = 0; k < 4; ++k)
					{
						if(k == 0)
						{
							CurNeighbor = TargetCell.m_NeighborLeft;
						}
						else if(k == 1)
						{
							CurNeighbor = TargetCell.m_NeighborRight;
						}
						else if(k == 2)
						{
							CurNeighbor = TargetCell.m_NeighborTop;
						}
						else if(k == 3)
						{
							CurNeighbor = TargetCell.m_NeighborBottom;
						}
						if(CurNeighbor)
						{
							if(m_ReachableCells.indexOf(CurNeighbor) < 0)
							{
								m_ReachableCells.push(CurNeighbor);
								m_DamagedCells.push(CurNeighbor);
							}
							CurNeighbor.takeDamage(SideDamage, 0);
						}
					}
				}
				if(m_ConnectedToOuter)
				{
					for(var z:int  = 0; z < m_DamagedCells.length; ++z)
					{
						m_DamagedCells[z].makeOuter();
					}
				}
			//}
			trace("!destroyTick");
		}
		///////////////////////////////////////////////////////////////////////////////////
		private function checkReachability()
		{
            trace("checkReachability");
			for(var i:int = 0; i < c_MapSize; ++i)
			{
				for(var j:int = 0; j < c_MapSize; ++j)
				{
					var CurCell:Cell = m_MapData[i][j];
					CurCell.makeInner();
				}
			}
			var NeighborCells:Array = new Array();
			NeighborCells.push(m_MapData[0][0]);
			for(var k:int = 0; NeighborCells.length > 0 && k < c_MapSize*c_MapSize; k++)
			{
				var CurrentCell = NeighborCells[0];
				CurrentCell.makeOuter();
				if(!CurrentCell.isWall())
				{
					CurrentCell.makeOuter();
					var CurNeighbor0:Cell;
					for(var s:int = 0; s < 4; ++s)
					{
						if(s == 0)
						{
							CurNeighbor0 = CurrentCell.m_NeighborLeft;
						}
						else if(s == 1)
						{
							CurNeighbor0 = CurrentCell.m_NeighborRight;
						}
						else if(s == 2)
						{
							CurNeighbor0 = CurrentCell.m_NeighborTop;
						}
						else if(s == 3)
						{
							CurNeighbor0 = CurrentCell.m_NeighborBottom;
						}
						if(CurNeighbor0 && CurNeighbor0.isInner() && NeighborCells.indexOf(CurNeighbor0) < 0)
						{
							NeighborCells.push(CurNeighbor0);
						}
					}
				}
				NeighborCells.splice(0, 1);
			}
			
            trace("!checkReachability");
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		private function generateMountain()
		{
            trace("generateMountain");
			
			for(var i:int = 0; i < c_MapSize; ++i)
			{
				for(var j:int = 0; j < c_MapSize; ++j)
				{
					var CurCell:Cell = m_MapData[i][j];
					var dx:int = i - c_MapSize/2;
					var dy:int = j - c_MapSize/2;
					var PositivePosition = Math.abs(dx + dy + (Math.random() - 0.5) * c_MountainRandomFactor);
					var NegativePosition = Math.abs(dx - dy + (Math.random() - 0.5) * c_MountainRandomFactor);
					var RangePosition = Math.sqrt(dx*dx + dy*dy) + (Math.random() - 0.5) * c_MountainRandomFactor;
					if(PositivePosition > c_MapSize/2 || NegativePosition > c_MapSize/2 || RangePosition > c_MapSize*3/7)
					{
						CurCell.makeOuter();
						CurCell.breakWall();
					}
				}
			}
            trace("!generateMountain");
		}
		///////////////////////////////////////////////////////////////////////////////////
		private function generateArray()
		{
            trace("generateArray");
			for(var i:int = 0; i < c_MapSize; ++i)
			{
				m_MapData[i] = new Array(c_MapSize);
				for(var j:int = 0; j < c_MapSize; ++j)
				{
					var NewCell:Cell = new Game.Cell(i, j);
					
					m_MapData[i][j] = NewCell;
					if(i > 0)
					{
						NewCell.m_NeighborLeft = m_MapData[i-1][j];
						m_MapData[i-1][j].m_NeighborRight = NewCell;
					}
					if(j > 0)
					{
						NewCell.m_NeighborTop = m_MapData[i][j-1];
						m_MapData[i][j-1].m_NeighborBottom = NewCell;
					}
				}
			}
            trace("!generateArray");
		}		///////////////////////////////////////////////////////////////////////////////////
		private function renderMap()
		{
            trace("renderMap");
			if(m_Drawlayer)
			{
				this.removeChild(m_Drawlayer);
				// we do not free memory
				//delete(m_Drawlayer);
			}
			m_Drawlayer = new flash.display.MovieClip();
			this.addChild(m_Drawlayer);
			
			
			for(var i:int = 0; i < c_MapSize; ++i)
			{
				for(var j:int = 0; j < c_MapSize; ++j)
				{
					var CurCell = m_MapData[i][j];
					//m_Drawlayer.graphics.lineStyle(2, 0x990000, .75);
					if(CurCell.m_Wall)
					{
						m_Drawlayer.graphics.beginFill(0x00FF00, CurCell.m_Durability/10);
						m_Drawlayer.graphics.moveTo(i * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo((i + 1) * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo((i + 1) * c_CellSize * m_Scale, (j + 1) * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo(i * c_CellSize * m_Scale, (j + 1) * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo(i * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
					}
					else
					{
						m_Drawlayer.graphics.beginFill(0xFF0000);
						m_Drawlayer.graphics.moveTo(i * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo((i + 1) * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo((i + 1) * c_CellSize * m_Scale, (j + 1) * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo(i * c_CellSize * m_Scale, (j + 1) * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo(i * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
					}
					
					// Draw shadow
					var Darken:Number = CurCell.m_Illumination;
					if(CurCell.isInner())
					{
						m_Drawlayer.graphics.beginFill(0x000000, Darken);
						m_Drawlayer.graphics.moveTo(i * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo((i + 1) * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo((i + 1) * c_CellSize * m_Scale, (j + 1) * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo(i * c_CellSize * m_Scale, (j + 1) * c_CellSize * m_Scale);
						m_Drawlayer.graphics.lineTo(i * c_CellSize * m_Scale, j * c_CellSize * m_Scale);
					}
				}
			}
            trace("!renderMap");
		}
    }
}