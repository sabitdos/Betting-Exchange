﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BetEx247.Core.XML;
using System.Xml;
using System.Xml.XPath;

namespace BetEx247.Plugin.XMLParser
{
    public class PinnacleSportsParser : IXMLParser
    {
        public static List<Sport> _lstSport;
        public static List<Event> _lstEvent;
        public static List<Match> _lstMatch;
        public static List<Bet> _lstBet;
        public static List<Choice> _lstChoice;

        public PinnacleSportsParser()
        {
            ReadXML();
        }

        public virtual void ReadXML()
        {
            string urlPathSport = "http://api.pinnaclesports.com/v1/sports";
            string urlPathLeague = "http://api.pinnaclesports.com/v1/leagues?sportid={0}";
            string urlPathFeed = "http://api.pinnaclesports.com/v1/feed?sportid={0}&leagueid={1}&clientid=PN514368&apikey=4235dc98-c16d-45f7-a74d-d68861e80a47&islive=0&currencycode=usd";
            _lstSport = new List<Sport>();
            _lstEvent = new List<Event>();
            _lstMatch = new List<Match>();
            _lstBet = new List<Bet>();
            _lstChoice = new List<Choice>();
            //sport
            XmlTextReader readerSport = new XmlTextReader(urlPathSport);
            // Skip non-significant whitespace  
            readerSport.WhitespaceHandling = WhitespaceHandling.Significant;
            XPathDocument doc = new XPathDocument(readerSport, XmlSpace.Preserve);
            XPathNavigator nav = doc.CreateNavigator();

            XPathExpression exprSport;
            exprSport = nav.Compile("/rsp/sports/sport");
            XPathNodeIterator iteratorSport = nav.Select(exprSport);
            try
            {
                int _sportId = 0;
                int _eventId = 0;
                long _matchId = 0;
                long _betId = 0;
                long _choiceId = 0;

                while (iteratorSport.MoveNext())
                {
                    XPathNavigator _sportNameNavigator = iteratorSport.Current.Clone();
                    _sportId = Convert.ToInt32(_sportNameNavigator.GetAttribute("id", ""));
                    Sport _sport = new Sport();
                    _sport.sportId = Convert.ToInt32(_sportNameNavigator.GetAttribute("id", ""));
                    _sport.sportName = _sportNameNavigator.Value;
                    _lstSport.Add(_sport);
                    //league- event
                    XmlTextReader readerLeague = new XmlTextReader(string.Format(urlPathLeague, _sportId));
                    readerLeague.WhitespaceHandling = WhitespaceHandling.Significant;
                    XPathDocument docLeague = new XPathDocument(readerLeague, XmlSpace.Preserve);
                    XPathNavigator navLeague = docLeague.CreateNavigator();

                    XPathExpression exprLeague;
                    exprLeague = navLeague.Compile("/rsp/leagues/league");
                    XPathNodeIterator iteratorLeague = navLeague.Select(exprLeague);

                    while (iteratorLeague.MoveNext())
                    {
                        XPathNavigator _eventNameNavigator = iteratorLeague.Current.Clone();
                        Event _event = new Event();
                        _eventId = Convert.ToInt32(_eventNameNavigator.GetAttribute("id", ""));
                        _event.eventId = _eventId;
                        _event.sportId = _sportId;
                        _event.eventName = _eventNameNavigator.Value;
                        _lstEvent.Add(_event);
                        //match - home team - awayteam  
                        XmlTextReader readerMatch = new XmlTextReader(string.Format(urlPathFeed, _sportId, _eventId));
                        readerMatch.WhitespaceHandling = WhitespaceHandling.Significant;
                        XPathDocument docMatch = new XPathDocument(readerMatch, XmlSpace.Preserve);
                        XPathNavigator navMatch = docMatch.CreateNavigator();

                        XPathExpression exprematch;
                        exprematch = navMatch.Compile("/rsp/fd/sports/sport/leagues/league");
                        XPathNodeIterator iteratorMatch = navMatch.Select(exprematch);
                        while (iteratorMatch.MoveNext())
                        {
                            XPathNavigator _matchNameNavigator = iteratorMatch.Current.Clone();

                            XPathExpression exprematchEvent;
                            exprematchEvent = _matchNameNavigator.Compile("events/event");
                            XPathNodeIterator iteratorMatchEvent = _matchNameNavigator.Select(exprematchEvent);
                            while (iteratorMatchEvent.MoveNext())
                            {
                                _matchId++;
                                XPathNavigator _matchEventNameNavigator = iteratorMatchEvent.Current.Clone();

                                Match _match = new Match();
                                _match.matchId = _matchId;
                                _match.eventId = _eventId;
                                //_match.nameMatch = _matchNameNavigator.GetAttribute("name", "");
                                _match.homeTeam = _matchEventNameNavigator.SelectSingleNode("homeTeam").SelectSingleNode("name").Value;
                                _match.awayTeam = _matchEventNameNavigator.SelectSingleNode("awayTeam").SelectSingleNode("name").Value;
                                _match.startTime = Convert.ToDateTime(_matchEventNameNavigator.SelectSingleNode("startDateTime").Value);
                                _lstMatch.Add(_match);

                                if (_matchNameNavigator.HasChildren)
                                {
                                    XPathExpression exprebet;
                                    exprebet = _matchNameNavigator.Compile("bets/bet");
                                    XPathNodeIterator iteratorBet = _matchNameNavigator.Select(exprebet);
                                    while (iteratorBet.MoveNext())
                                    {
                                        _betId++;
                                        XPathNavigator _betNameNavigator = iteratorBet.Current.Clone();
                                        Bet _bet = new Bet();
                                        _bet.betId = _betId;
                                        _bet.matchId = _matchId;
                                        _bet.betName = _betNameNavigator.GetAttribute("name", "");
                                        _bet.betCode = _betNameNavigator.GetAttribute("code", "");
                                        _lstBet.Add(_bet);

                                        if (_betNameNavigator.HasChildren)
                                        {
                                            XPathExpression exprechoice;
                                            exprechoice = _betNameNavigator.Compile("choice");
                                            XPathNodeIterator iteratorChoice = _betNameNavigator.Select(exprechoice);
                                            while (iteratorChoice.MoveNext())
                                            {
                                                _choiceId++;
                                                XPathNavigator _choiceNameNavigator = iteratorChoice.Current.Clone();
                                                Choice _choice = new Choice();
                                                _choice.choiceId = _choiceId;
                                                _choice.betId = _betId;
                                                _choice.choiceName = _choiceNameNavigator.GetAttribute("name", "");
                                                _choice.odd = _choiceNameNavigator.GetAttribute("odd", "");
                                                _lstChoice.Add(_choice);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                //throw new Exception(ex.Message);
            }
        }

        public List<Sport> getAllSport()
        {
            return _lstSport;
        }

        public List<Event> getAllEvent()
        {
            return _lstEvent;
        }

        public List<Match> getAllMatch()
        {
            return _lstMatch;
        }

        public List<Bet> getAllBet()
        {
            return _lstBet;
        }

        public List<Choice> getAllChoice()
        {
            return _lstChoice;
        }
    }
}
