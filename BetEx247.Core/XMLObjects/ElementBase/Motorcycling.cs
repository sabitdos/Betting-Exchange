﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XMLBettingObjects.ElementsBase;
using XMLBettingObjects.Event;
namespace XMLBettingObjects.ElementsBase
{
    class Motorcycling:BaseSport
    {
         public Motorcycling()
        {
        }
         public Motorcycling(int id, String name, List<EventObject> events)
             : base(id, name, events)
        {
           
        }
    }
}
