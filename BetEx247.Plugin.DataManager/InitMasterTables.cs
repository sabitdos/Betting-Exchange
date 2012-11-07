﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Linq;
using System.Diagnostics;
using BetEx247.Data.Model;
using BetEx247.Data.DAL.Sports;

using BetEx247.Plugin.DataManager.XMLObjects.Sport;

using BetEx247.Plugin.DataManager.XMLObjects.SoccerCountry;

using BetEx247.Plugin.DataManager.XMLObjects.SoccerLeague;
using BetEx247.Core;
namespace BetEx247.Plugin.DataManager
{
   public  class InitMasterTables
    {
       public List<Bet247xSport> sports = new List<Bet247xSport>();
     //  public List<SoccerCountry> countries = new List<SoccerCountry>();
      // public List<SoccerLeague> leagues = new List<SoccerLeague>();
       // init Sport Table
       public void InitSportTable()
       {
           String strPath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().CodeBase);

          // XmlTextReader textReader = new XmlTextReader("E:\\beauty\\Dropbox\\Betting\\code\\sport.xml");
           XDocument doc = XDocument.Load(Constant.SourceXML.MASTERXMLSOURCE + "\\sport.xml");

           foreach (XElement element in doc.Root.Nodes())
           {
               //element.Attribute("id").Value
              // Debug.WriteLine(element.Name);
               Bet247xSport sport = new Bet247xSport();
               sport.ID = int.Parse( element.Attribute("id").Value);
               sport.SportName = element.Value;
               SportService sportSvr = new SportService();

               sportSvr.Insert(sport.getSport());
               sports.Add(sport);

           }

       }
       // Init SoccerCountry , SoccerLeague
       public void InitSoccerCountryTable()
       {
           String strPath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().CodeBase);

           XDocument doc = XDocument.Load(Constant.SourceXML.MASTERXMLSOURCE + "\\countryleague.xml");

           foreach (XElement element in doc.Root.Nodes())
           {
               // Country
               Bet247xSoccerCountry soccercountry = new Bet247xSoccerCountry();
               SoccerCountry _soccercountry = new SoccerCountry();
               SoccerCountryService soccerCountrySvr = new SoccerCountryService();
               soccercountry.ID = int.Parse(element.Attribute("id").Value);
               soccercountry.Country = element.Attribute("name").Value;
               soccercountry.International = element.Attribute("international") == null ? false : true;
              
               XElement urlelements = element.XPathSelectElement("urls");
               foreach (XElement url in urlelements.Nodes())
               {
                   if(url.Attribute("name").Value.Equals("Goalserve_OddsFeed")){
                       soccercountry.Goalserve_OddsFeed=url.Value;
                   }
                   if(url.Attribute("name").Value.Equals("Goalserve_LivescoreFeed")){
                       soccercountry.Goalserve_LivescoreFeed=url.Value;
                   }
                   if(url.Attribute("name").Value.Equals("Betclick_OddsFeed")){
                       soccercountry.Betclick_OddsFeed=url.Value;
                   }
                   
               }
               _soccercountry = new SoccerCountry()
               {
                   ID = soccercountry.ID,
                   Country = soccercountry.Country,
                   International = soccercountry.International,
                   Betclick_OddsFeed = soccercountry.Betclick_OddsFeed,
                   Goalserve_LivescoreFeed = soccercountry.Goalserve_LivescoreFeed,
                   Goalserve_OddsFeed = soccercountry.Goalserve_OddsFeed,
                   EntityKey = soccercountry.EntityKey
               };
               soccerCountrySvr.Insert(soccercountry.getSoccerCountry());

               //League
               IEnumerable<XElement> LeagueElements = element.XPathSelectElements("leagues");
               // 3 loop: 1 web, 2 feed, 3 betclick
               List<Bet247xSoccerLeague> _soccerLeagues = new List<Bet247xSoccerLeague>();
               foreach (XElement leagueElement in LeagueElements)
               {
                   foreach (XElement le in leagueElement.Nodes())
                   {
                       Bet247xSoccerLeague temp = new Bet247xSoccerLeague();
                       _soccerLeagues.Add(temp);
                   }
                   break;
               }
               foreach (XElement leagueElement in LeagueElements)
               {
                       foreach (XElement le in leagueElement.Nodes())
                       {
                           _soccerLeagues[int.Parse(le.Attribute("id").Value) - 1].CountryID = soccercountry.ID;
                            _soccerLeagues[int.Parse(le.Attribute("id").Value) - 1].ID=int.Parse(le.Attribute("id").Value);
                            _soccerLeagues[int.Parse(le.Attribute("id").Value) - 1].SportID = 1;
                           if (leagueElement.Attribute("name").Value.Equals("web"))
                           {
                               _soccerLeagues[int.Parse(le.Attribute("id").Value)-1].LeagueName_WebDisplay = le.Attribute("name").Value;
                           }
                           if (leagueElement.Attribute("name").Value.Equals("feed"))
                           {
                               _soccerLeagues[int.Parse(le.Attribute("id").Value)-1].LeagueName_Goalserve = le.Attribute("name").Value;
                           }
                           if (leagueElement.Attribute("name").Value.Equals("betclick"))
                           {
                               _soccerLeagues[int.Parse(le.Attribute("id").Value)-1].LeagueName_Betclick = le.Attribute("name").Value;
                           }
                      
                          
 
                       }
                       // leagues.Add();
                      // _soccerLeagues[].CountryID = soccercountry.ID;
                       //   _soccerLeague.SoccerCountry = soccercountry;
                       // sports[0].SoccerLeagues.Add(_soccerLeague);
                      
                  
               }
               soccercountry.Bet247xSoccerLeagues.AddRange(_soccerLeagues);
               // Save to database
               for (int l = 0; l < _soccerLeagues.Count;l++ )

               {
                   SoccerLeagueService _soccerLeagueSvr = new SoccerLeagueService() ;
                  
                   _soccerLeagueSvr.Insert(_soccerLeagues[l].getSoccerLeague());
               }
               sports[0].Bet247xSoccerCountries.Add(soccercountry);
              

           }
       }
       // Init Match Status
       public void InitMatchStatusTable()
       {
           String strPath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().CodeBase);

           // XmlTextReader textReader = new XmlTextReader("E:\\beauty\\Dropbox\\Betting\\code\\sport.xml");
           XDocument doc = XDocument.Load(Constant.SourceXML.MASTERXMLSOURCE + "\\matchstatus.xml");

           foreach (XElement element in doc.Root.Nodes())
           {
               //element.Attribute("id").Value
               Debug.WriteLine(element.Name);
               MatchStatu obj = new MatchStatu();
               obj.ID = short.Parse(element.Attribute("id").Value);
               obj.Reason = element.Attribute("name").Value;
               MatchStatusService sportSvr = new MatchStatusService();
               sportSvr.Insert(obj);

           }

       }   
       // Init Bet Status
       public void InitBetStatusTable()
       {
           String strPath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().CodeBase);
           
           // XmlTextReader textReader = new XmlTextReader("E:\\beauty\\Dropbox\\Betting\\code\\sport.xml");
           XDocument doc = XDocument.Load(Constant.SourceXML.MASTERXMLSOURCE + "\\betstatus.xml");

           foreach (XElement element in doc.Root.Nodes())
           {
               //element.Attribute("id").Value
               Debug.WriteLine(element.Name);
               BetStatu obj = new BetStatu();
               obj.ID = short.Parse(element.Attribute("id").Value);
               obj.Status = element.Attribute("name").Value;
               BetStatusService sportSvr = new BetStatusService();
               sportSvr.Insert(obj);

           }

       }
    }
}