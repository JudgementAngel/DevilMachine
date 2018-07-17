using System;
using System.Collections.Generic;
using System.Text;


class AudioManager
{
    private AudioManager _mInstance;

    public bool isPlayAudio = true;

    public AudioManager Instance
    {
        get
        {
            if (_mInstance == null)
            {
                _mInstance = new AudioManager();
            }
            return _mInstance;
        } 
    }

    private AudioManager()
    {
        
    }

    public void Play()
    {
        if (isPlayAudio)
        {
//TODO;
        }
    }

}
