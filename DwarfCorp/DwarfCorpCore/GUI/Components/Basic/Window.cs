﻿// Window.cs
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
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;

namespace DwarfCorp
{
    public class Window : Panel
    {
        public Rectangle DragArea { get; set; }
        public Rectangle ResizeArea { get; set; }
        public bool IsDragging { get; set; }
        public bool IsResizing { get; set; }
        public bool IsDraggable { get; set; }
        public bool IsResizeable { get; set; }
        public Point DragStart { get; set; }
        public Point ResizeStartSize { get; set; }
        public Point ResizeStartPosition { get; set; }
        public Button CloseButton { get; set; }

        public enum WindowButtons
        {
            NoButtons,
            CloseButton
        }

        public Window(DwarfGUI gui, GUIComponent parent, WindowButtons buttons = WindowButtons.NoButtons) 
            : base(gui, parent)
        {
            IsDraggable = true;
            IsResizeable = true;
            IsDragging = false;
            IsResizing = false;
            Mode = buttons == WindowButtons.NoButtons ? PanelMode.Window : PanelMode.WindowEx;

            if (buttons == WindowButtons.CloseButton)
            {
                CloseButton = new Button(GUI, this, "", GUI.DefaultFont, Button.ButtonMode.ImageButton, GUI.Skin.GetSpecialFrame(GUISkin.Tile.CloseButton));
                CloseButton.OnClicked += CloseButton_OnClicked;
            }
        }

        void CloseButton_OnClicked()
        {
            IsVisible = false;
        }


        void Window_OnPressed()
        {
            if (IsDragging || IsResizing)
            {
                return;
            }

            MouseState mouseState = Mouse.GetState();

            if (mouseState.LeftButton != ButtonState.Pressed)
            {
                return;
            }

            if (DragArea.Contains(mouseState.X, mouseState.Y))
            {
                IsDragging = true;
                DragStart = new Point(-LocalBounds.X + mouseState.X, -LocalBounds.Y + mouseState.Y);
            }
            else if (ResizeArea.Contains(mouseState.X, mouseState.Y))
            {
                IsResizing = true;
                ResizeStartSize = new Point(LocalBounds.Width, LocalBounds.Height);
                ResizeStartPosition = new Point(mouseState.X, mouseState.Y);
            }
        }

        public override void Update(DwarfTime time)
        {
            if (IsVisible)
            {
                UpdateAreas();
                Window_OnPressed();

                if (IsDragging)
                {
                    Drag();
                }

                if (IsResizing)
                {
                    Resize();
                }
            }
            base.Update(time);
        }

        public void Resize()
        {
            if (!IsResizeable) return;

            MouseState mouseState = Mouse.GetState();
            if (mouseState.LeftButton != ButtonState.Pressed)
            {
                IsResizing = false;
                return;
            }
            int mx = mouseState.X;
            int my = mouseState.Y;
            int dx = mx - ResizeStartPosition.X;
            int dy = my - ResizeStartPosition.Y;
            LocalBounds = new Rectangle(LocalBounds.X, LocalBounds.Y, Math.Max(ResizeStartSize.X + dx, 64), Math.Max(ResizeStartSize.Y + dy, 64));

        }

        public void Drag()
        {
            if (!IsDraggable) return;

            MouseState mouseState = Mouse.GetState();
            if (mouseState.LeftButton != ButtonState.Pressed)
            {
                IsDragging = false;
                return;
            }
            int mx = mouseState.X;
            int my = mouseState.Y;
            int x = mx - DragStart.X;
            int y = my - DragStart.Y;
            LocalBounds = new Rectangle(x, y, Math.Max(LocalBounds.Width, 64), Math.Max(LocalBounds.Height, 64));

        }


        public override bool IsMouseOverRecursive()
        {
            MouseState mouseState = Mouse.GetState();
            Rectangle expanded = GlobalBounds;
            expanded.Inflate(32, 32);
            return this != GUI.RootComponent && IsVisible && (expanded.Contains(mouseState.X, mouseState.Y) || DragArea.Contains(mouseState.X, mouseState.Y) || ResizeArea.Contains(mouseState.X, mouseState.Y) || base.IsMouseOverRecursive());
        }

        public virtual void UpdateAreas()
        {
            DragArea = new Rectangle(GlobalBounds.X - 32, GlobalBounds.Y - 32, GlobalBounds.Width + 32, 31);
            ResizeArea = new Rectangle(GlobalBounds.Right - 32, GlobalBounds.Bottom - 32, 64, 64);

            if (CloseButton != null)
            {
                CloseButton.LocalBounds = new Rectangle(GlobalBounds.Width - 8, -24, 32, 32);
            }
        }
    }
}
 