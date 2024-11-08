// This file is part of the Smart Home
// Program complex distribution https://github.com/e154/smart-home
// Copyright (C) 2016-2023, Filippov Alex
//
// This library is free software: you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library.  If not, see
// <https://www.gnu.org/licenses/>.

package main

import (
	"context"
	"embed"

	"github.com/e154/bus"

	"github.com/e154/smart-home-vosk/version"
	"github.com/e154/smart-home/pkg/events"
	"github.com/e154/smart-home/pkg/logger"
	m "github.com/e154/smart-home/pkg/models"
	"github.com/e154/smart-home/pkg/plugins"
	triggersTypes "github.com/e154/smart-home/pkg/plugins/triggers"
)

var (
	log = logger.MustGetLogger("plugins.vosk")
)

//go:embed *.md
var F embed.FS

var _ plugins.Pluggable = (*Plugin)(nil)
var _ plugins.Installable = (*Plugin)(nil)

type Plugin struct {
	*plugins.Plugin
	registrar triggersTypes.IRegistrar
	trigger   *Trigger
	stt       STT
	settings  m.Attributes
	msgQueue  bus.Bus
}

// New ...
func New() plugins.Pluggable {
	p := &Plugin{
		Plugin:   plugins.NewPlugin(),
		msgQueue: bus.NewBus(),
	}
	p.F = F
	return p
}

// Load ...
func (p *Plugin) Load(ctx context.Context, service plugins.Service) (err error) {
	if err = p.Plugin.Load(ctx, service, p.ActorConstructor); err != nil {
		return
	}

	// load settings
	p.settings, err = p.LoadSettings(p)
	if err != nil {
		log.Warn(err.Error())
		p.settings = NewSettings()
	}

	// register trigger
	if triggersPlugin, ok := service.Plugins()["triggers"]; ok {
		if p.registrar, ok = triggersPlugin.(triggersTypes.IRegistrar); ok {
			p.trigger = NewTrigger(p.msgQueue)
			if err = p.registrar.RegisterTrigger(p.trigger); err != nil {
				log.Error(err.Error())
				return
			}
		}
	}

	var sttModel = defaultModel
	if p.settings[AttrModel] != nil && p.settings[AttrModel].String() != "" {
		sttModel = p.settings[AttrModel].String()
	}

	p.stt = NewVosk(modelPath, sttModel, p.Service.Crawler())
	p.stt.Start()

	_ = p.Service.EventBus().Subscribe("system/stt", p.eventHandler)
	return
}

// Unload ...
func (p *Plugin) Unload(ctx context.Context) (err error) {
	_ = p.Service.EventBus().Unsubscribe("system/stt", p.eventHandler)
	err = p.Plugin.Unload(ctx)

	p.trigger.Shutdown()

	if err = p.registrar.UnregisterTrigger(Name); err != nil {
		log.Error(err.Error())
		return err
	}

	p.stt.Shutdown()

	return
}

// ActorConstructor ...
func (p *Plugin) ActorConstructor(entity *m.Entity) (actor plugins.PluginActor, err error) {
	return
}

// Name ...
func (p *Plugin) Name() string {
	return Name
}

func (p *Plugin) eventHandler(topic string, msg interface{}) {

	switch v := msg.(type) {
	case events.CommandSTT:
		text, err := p.stt.STT(v.Payload, false)
		if err != nil {
			log.Error(err.Error())
			return
		}
		p.msgQueue.Publish("/", text)
	}
}

// Depends ...
func (p *Plugin) Depends() []string {
	return nil
}

// Version ...
func (p *Plugin) Version() string {
	return version.Version
}

// Options ...
func (p *Plugin) Options() m.PluginOptions {
	return m.PluginOptions{
		Triggers: true,
		Setts:    NewSettings(),
		Javascript: m.PluginOptionsJs{
			Methods:   map[string]string{},
			Variables: nil,
		},
		TriggerParams: NewTriggerParams(),
	}
}

func (p *Plugin) Install() error {
	log.Debug("Install ...")
	return nil
}

func (p *Plugin) Uninstall() error {
	log.Debug("Uninstall ...")
	return nil
}
