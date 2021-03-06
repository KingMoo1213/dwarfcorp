﻿// Thought.cs
// 
//  Modified MIT License (MIT)
//  
//  Copyright (c) 2015 Completely Fair Games Ltd.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// The following content pieces are considered PROPRIETARY and may not be used
// in any derivative works, commercial or non commercial, without explicit 
// written permission from Completely Fair Games:
// 
// * Images (sprites, textures, etc.)
// * 3D Models
// * Sound Effects
// * Music
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Newtonsoft.Json;

namespace DwarfCorp
{
    [JsonObject(IsReference = true)]
    public class Thought
    {
        public string Description { get; set; }
        public float HappinessModifier { get; set; }
        public DateTime TimeStamp { get; set; }
        public TimeSpan TimeLimit { get; set; }
        public ThoughtType Type { get; set; }

        public enum ThoughtType
        {
            Slept,
            SleptOnGround,
            TookDamage,
            KilledThing,
            Talked,
            FeltCold,
            FeltHot,
            FriendDied,
            Frightened,
            HadAle,
            AteFood,
            FeltHungry,
            FeltSleepy,
            GotPaid,
            NotPaid,
            IsOverQualified,
            GotPromoted,
            JustArrived,
            Other,
            Farmed,
            Crafted,
            Researched,
            Magic
        }

        public static Thought CreateStandardThought(ThoughtType type, DateTime time)
        {
            string description = "";
            float happiness = 0.0f;
            TimeSpan limit = new TimeSpan(0, 1, 0, 0);
            switch (type)
            {
                case ThoughtType.Magic:
                    description = "A strange giddiness overcomes me.";
                    happiness = 100.0f;
                    limit = new TimeSpan(1, 0, 0, 0);
                    break;
                case ThoughtType.Slept:
                    description = "I slept recently.";
                    happiness = 5.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.SleptOnGround:
                    description = "I slept on the ground.";
                    happiness = -6.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.TookDamage:
                    description = "I got hurt recently.";
                    happiness = -5.0f;
                    limit = new TimeSpan(2, 0, 0, 0);
                    break;
                case ThoughtType.Talked:
                    description = "I spoke to a friend recently.";
                    happiness = 5.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.FeltCold:
                    description = "I felt very cold recently.";
                    happiness = -2.0f;
                    limit = new TimeSpan(0, 4, 0, 0);
                    break;
                case ThoughtType.FeltHot:
                    description = "I felt very hot recently.";
                    happiness = -2.0f;
                    limit = new TimeSpan(0, 4, 0, 0);
                    break;
                case ThoughtType.FriendDied:
                    description = "A friend died recently.";
                    happiness = -50.0f;
                    limit = new TimeSpan(2, 0, 0, 0);
                    break;
                case ThoughtType.Frightened:
                    description = "I was frightened recently.";
                    happiness = -2.0f;
                    limit = new TimeSpan(0, 4, 0, 0);
                    break;
                case ThoughtType.HadAle:
                    description = "I had good ale recently.";
                    happiness = 10.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.AteFood:
                    description = "I ate good food recently.";
                    happiness = 5.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.FeltHungry:
                    description = "I was hungry recently.";
                    happiness = -3.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.FeltSleepy:
                    description = "I was sleepy recently.";
                    happiness = -3.0f;
                    limit = new TimeSpan(0, 4, 0, 0);
                    break;
                case ThoughtType.GotPaid:
                    description = "I got paid recently.";
                    happiness = 10.0f;
                    limit = new TimeSpan(1, 0, 0, 0);
                    break;
                 case ThoughtType.NotPaid:
                    description = "I have not been paid!";
                    happiness = -25.0f;
                    limit = new TimeSpan(1, 0, 0, 0);
                    break;
                case ThoughtType.IsOverQualified:
                    description = "I am overqualified for this job.";
                    happiness = -10.0f;
                    limit = new TimeSpan(1, 0, 0, 0);
                    break;
                case ThoughtType.GotPromoted:
                    description = "I got promoted recently.";
                    happiness = 20.0f;
                    limit = new TimeSpan(3, 0, 0, 0);
                    break;
                case ThoughtType.JustArrived:
                    description = "I just arrived to this new land.";
                    happiness = 20.0f;
                    limit = new TimeSpan(3, 0, 0, 0);
                    break;
                case ThoughtType.KilledThing:
                    description = "I killed somehing!";
                    happiness = 0.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.Crafted:
                    description = "I crafted something!";
                    happiness = 1.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.Farmed:
                    description = "I farmed something!";
                    happiness = 1.0f;
                    limit = new TimeSpan(0, 4, 0, 0);
                    break;
                case ThoughtType.Researched:
                    description = "I researched something!";
                    happiness = 10.0f;
                    limit = new TimeSpan(0, 8, 0, 0);
                    break;
                case ThoughtType.Other:
                    return new Thought()
                    {
                        Type = type
                    };
                    break;
            }

            return new Thought()
            {
                Description = description,
                HappinessModifier = happiness,
                TimeLimit = limit,
                TimeStamp = time,
                Type = type
            };
        }

        public bool IsOver(DateTime time)
        {
            TimeSpan elapsed = time - TimeStamp;
            return elapsed >= TimeLimit;
        }
    }
}
