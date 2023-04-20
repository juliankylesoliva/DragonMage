using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioPlayer : MonoBehaviour
{
    private AudioSource audioSrc;

    void Awake()
    {
        audioSrc = this.gameObject.GetComponent<AudioSource>();
    }

    public void PlaySound(string name, float volume = 1f)
    {
        audioSrc.clip = SoundFactory.GetClip(name);
        if (audioSrc.clip != null)
        {
            audioSrc.volume = volume;
            audioSrc.Play();
        }
    }
}
