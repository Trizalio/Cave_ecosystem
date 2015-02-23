package Game
{
	import Game.Cell;
	import Game.Utils;
    import flash.display.MovieClip;
    public class Map extends MovieClip
    {
		// Constants
		private static var c_CellSize:int = 10;
		private static var c_MapSize:int = 100;
		private static var c_MountainRandomFactor:int = c_MapSize/40;

		
		// Outer charasteristics
		private var m_Scale:Number = 100/c_MapSize;
		
		private var m_Drawlayer:flash.display.MovieClip;
		private var m_MapData:Array = new Array(c_MapSize); 
		
		///////////////////////////////////////////////////////////////////////////////////
        public function Map()
        {
            trace("Map");
			generateArray();
			generateMountain();
			createCave();
			//checkReachability();
			renderMap();
            trace("!Map");
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
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		private function createNewSource(StartCell):void
		{
			var ReachableCells:Array = new Array();
			var DamagedCells:Array = new Array();
			ReachableCells.push(StartCell);
			DamagedCells.push(StartCell);
			
			var ConnectedToOuter:Boolean = false;
			for(var i:int = 0; i < c_MapSize*c_MapSize/30 && !ConnectedToOuter; ++i)
			{
            	//trace("looking for target");
				var MinDurability = Cell.c_DurabilityMax;
				var TargetCellNumber:int = -1;
				for(var j:int = 0; j < ReachableCells.length; ++j)
				{
					var CurCell:Cell = ReachableCells[j];
					if(MinDurability > CurCell.m_Durability)
					{
						if(CurCell.m_Durability <= 0)
						{
							var CurNeighbor0:Cell;
							/*for(var s:int = 0; s < 4; ++s)
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
									if(ReachableCells.indexOf(CurNeighbor) < 0)
									{
										ReachableCells.push(CurNeighbor0);
										DamagedCells.push(CurNeighbor0);
									}
								}
							}*/
							if(!CurCell.isInner())
							{
								ConnectedToOuter = true;
							}
							ReachableCells.splice(j, 1);
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
					var TargetCell:Cell = ReachableCells[TargetCellNumber];
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
							if(ReachableCells.indexOf(CurNeighbor) < 0)
							{
								ReachableCells.push(CurNeighbor);
								DamagedCells.push(CurNeighbor);
							}
							CurNeighbor.takeDamage(SideDamage, 0);
						}
					}
				}
				if(ConnectedToOuter)
				{
					for(var z:int  = 0; z < DamagedCells.length; ++z)
					{
						DamagedCells[z].makeOuter();
					}
				}
			}
		}
		/*private function createNewSource2(StartCell):void
		{
			var ReachableCells:Array = new Array();
			ReachableCells.push(StartCell);
			
			var NotConnectedToOuter:Boolean = true;
			for(var i:int = 0; i < c_MapSize*c_MapSize/900 && NotConnectedToOuter; ++i)
			{
            	//trace("looking for target");
				var MinDurability = Cell.c_DurabilityMax;
				var TargetCellNumber:int = -1;
				for(var j:int = 0; j < ReachableCells.length; ++j)
				{
					var CurCell:Cell = ReachableCells[j];
					if(MinDurability > CurCell.m_Durability)
					{
						if(CurCell.m_Durability <= 0)
						{
							ReachableCells.splice(j, 1);
							--j
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
					var TargetCell:Cell = ReachableCells[TargetCellNumber];
					var Damage:Number = Cell.c_DurabilityMax/2;
					var SideDamage:Number = Damage/2;
					var CurNeighbor:Cell;
					var NeighborsDamaged:int = 0;
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
						var Result:int = attemptToDamage(CurNeighbor, SideDamage);
						if(Result == 1)
						{
							++NeighborsDamaged;
						}
						else if(Result == 2)
						{
							++NeighborsDamaged;
							ReachableCells.push(CurNeighbor);
						}
					}
					if(TargetCell.takeDamage(Damage*(1 + 0.2*(4-NeighborsDamaged)), 0))
					{
						ReachableCells.splice(TargetCellNumber, 1);
					}
				}
			}
		}*/
		
		///////////////////////////////////////////////////////////////////////////////////
		private function createCave()
		{
            trace("createCave");
			
			var ReachableCells:Array = new Array();
			
			var Divider:uint = c_MapSize/10;
			var Step:uint = (c_MapSize-1)/Divider;
			for(var m:int = 0; m < c_MapSize; m += Step)
			{
				for(var n:int = 0; n < c_MapSize; n += Step)
				{
					if(m_MapData[m][n].m_Wall)
					{
						createNewSource(m_MapData[m][n]);
					}
				}
			}
			/*var StartCell:Cell = m_MapData[c_MapSize/2][c_MapSize/2];
			ReachableCells.push(StartCell);
			StartCell = m_MapData[0][c_MapSize/2];
			ReachableCells.push(StartCell);
			StartCell = m_MapData[c_MapSize/2][0];
			ReachableCells.push(StartCell);
			StartCell = m_MapData[c_MapSize - 1][c_MapSize/2];
			ReachableCells.push(StartCell);
			StartCell = m_MapData[c_MapSize/2][c_MapSize - 1];
			ReachableCells.push(StartCell);
            trace("first cell added");*/
			
			
			
			
            trace("!createCave");
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		// 0 - not a valid targe
		// 1 - do nothing
		// 2 - add
		private function attemptToDamage2(Target, Damage):int
		{
			if(!Target)
			{
				return 0;
			}
			if(!Target.m_Wall)
			{
				return 0;
			}
			var AlreadyInArray:Boolean = Target.m_Damaged;
			if(Target.takeDamage(Damage, 0))
			{
				// destroyed
				return 1;
			}
			if(AlreadyInArray)
			{
				// already in array, do nothing
				return 1;
			}
			else
			{
				// not in array, add
				return 2;
			}
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		private function attemptToDamage(Target, Damage):void
		{
			if(!Target)
			{
				return;
			}
			if(!Target.m_Wall)
			{
				return;
			}
			Target.takeDamage(Damage, 0);
		}
		
		///////////////////////////////////////////////////////////////////////////////////
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