// This file is part of the Smart Home
// Program complex distribution https://github.com/e154/smart-home
// Copyright (C) 2024, Filippov Alex
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

//go:build !test
// +build !test

package main

import vosk "github.com/alphacep/vosk-api/go"

type Worker struct {
	InUse bool
	Rec   *vosk.VoskRecognizer
}

func NewWorker(v *Vosk) (*Worker, error) {
	gpRecognizer, err := vosk.NewRecognizer(v.model, sampleRate)
	if err != nil {
		return nil, err
	}
	return &Worker{
		InUse: true,
		Rec:   gpRecognizer,
	}, nil
}
