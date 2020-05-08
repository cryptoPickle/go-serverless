package utils

import (
	"reflect"
)

type EventType string

type Event interface {
	Type() EventType
	Value() interface{}
}

type Values []interface{}

type Dispatcher struct {
	callbacks map[EventType][]Callback
}

type Callback func(Event) (interface{}, error)

func NewDispatcher() *Dispatcher {
	return &Dispatcher{callbacks: make(map[EventType][]Callback)}
}

func (d *Dispatcher) Register(eType EventType, callback Callback) {
	d.callbacks[eType] = append(d.callbacks[eType], callback)
}

func (d *Dispatcher) Remove(etype EventType, callback Callback) {
	ptr := reflect.ValueOf(callback).Pointer()
	callbacks := d.callbacks[etype]

	for id, cb := range callbacks {
		if reflect.ValueOf(cb).Pointer() == ptr {
			d.callbacks[etype] = append(callbacks[:id], callbacks[id+1:]...)
		}
	}
}

func (d *Dispatcher) Dispatch(etype EventType, value interface{}) (*Values, error) {
	e := &event{
		etype: etype,
		value: value,
	}
	var values Values
	for _, cb := range d.callbacks[etype] {
		cbv, err := cb(e)
		if err != nil {
			return nil, err
		}
		values = append(values, cbv)
	}
	return &values, nil
}

type event struct {
	etype EventType
	value interface{}
}

func (e event) Type() EventType {
	return e.etype
}

func (e event) Value() interface{} {
	return e.value
}
