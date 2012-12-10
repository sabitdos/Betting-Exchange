﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using BetEx247.Core.Infrastructure;
using BetEx247.Data.DAL;
using BetEx247.Data.Model;

namespace BetEx247.Web.Controllers
{
    public class LeagueController : Controller
    {
        //
        // GET: /League/

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult ByLeague(long? id, int? cid, int? sid)
        {
            ViewBag.tempLeague = id;
            ViewBag.ListSoccerLive = IoC.Resolve<IGuiService>().LiveInMatches(true, cid, sid);
            ViewBag.ListSoccerComming = IoC.Resolve<IGuiService>().UpCommingMatches(true, id, cid, sid, 7);
            if (id != null)
            {
                //SoccerCountry country = IoC.Resolve<IGuiService>().GetCountryByLeage(id.Value,cid.Value,sid.Value);
                //ViewBag.SoccerCountries = country;
                if (sid.Value == 1 || sid == null)
                {
                    SoccerCountry country = IoC.Resolve<IGuiService>().GetCountryByCountry(cid.Value);
                    ViewBag.SoccerCountries = country;
                }
                else
                {
                    SportCountry country = IoC.Resolve<IGuiService>().GetCountryByCountry(cid.Value, sid.Value);
                    ViewBag.SoccerCountries = country;
                }
                ViewBag.AllTournaments = IoC.Resolve<IGuiService>().GetTournamentByCountry(cid.Value, sid);
                ViewBag.LeagueDetail = IoC.Resolve<IGuiService>().GetSoccerLeague(id.Value, cid.Value, sid.Value);
                ViewBag.AllSport = IoC.Resolve<IGuiService>().GetAllSport(sid);
                ViewBag.SportId = sid;
            }
            return View();
        }

        public ActionResult ByCountry(int? id, int? sid)
        {
            ViewBag.ListSoccerLive = IoC.Resolve<IGuiService>().LiveInMatches(true, id, sid);
            ViewBag.ListSoccerComming = IoC.Resolve<IGuiService>().UpCommingMatches(true, 0, id, sid, 7);
            if (id != null)
            {
                if (sid.Value == 1 || sid == null)
                {
                    SoccerCountry country = IoC.Resolve<IGuiService>().GetCountryByCountry(id.Value);
                    ViewBag.SoccerCountries = country;
                }
                else
                {
                    SportCountry country = IoC.Resolve<IGuiService>().GetCountryByCountry(id.Value, sid.Value);
                    ViewBag.SoccerCountries = country;
                }
                ViewBag.AllTournaments = IoC.Resolve<IGuiService>().GetTournamentByCountry(id.Value, sid);
                ViewBag.AllSport = IoC.Resolve<IGuiService>().GetAllSport(sid);
            }
            ViewBag.SportId = sid;
            return View();
        }


    }
}
