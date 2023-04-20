using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempSound : MonoBehaviour
{
    AudioSource audioSrc;

    private float timeLeft = 0.25f;

    void Awake()
    {
        audioSrc = this.gameObject.GetComponent<AudioSource>();
    }

    void Update()
    {
        if (timeLeft > 0f)
        {
            timeLeft -= Time.deltaTime;
            if (timeLeft <= 0f)
            {
                GameObject.Destroy(this.gameObject);
            }
        }
    }

    public void Setup(AudioClip clip, float volume = 1f)
    {
        if (audioSrc.clip == null && clip != null)
        {
            audioSrc.clip = clip;
            audioSrc.volume = volume;
            audioSrc.Play();
            timeLeft += clip.length;
        }
    }
}
