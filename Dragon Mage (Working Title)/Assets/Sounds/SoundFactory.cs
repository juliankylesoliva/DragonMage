using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundFactory : MonoBehaviour
{
    [SerializeField] GameObject temporarySoundPrefab;
    [SerializeField] AudioClip[] clipList;

    private static Dictionary<string, AudioClip> clipDictionary;
    private static GameObject _temporarySoundPrefab;

    void Awake()
    {
        _temporarySoundPrefab = temporarySoundPrefab;
        Initialize();
    }

    private void Initialize()
    {
        if (clipDictionary == null)
        {
            clipDictionary = new Dictionary<string, AudioClip>();
            foreach (AudioClip a in clipList)
            {
                clipDictionary.Add(a.name, a);
            }
        }
    }

    public static AudioClip GetClip(string clipName)
    {
        if (clipDictionary != null && clipDictionary.ContainsKey(clipName))
        {
            return clipDictionary[clipName];
        }
        return null;
    }

    public static void SpawnSound(string clipName, Vector3 position, float volume = 1f, float pitch = 1f)
    {
        GameObject tempObj = Instantiate(_temporarySoundPrefab, position, Quaternion.identity);
        TempSound tempSound = tempObj.GetComponent<TempSound>();
        if (tempSound != null) { tempSound.Setup(GetClip(clipName), volume, pitch); }
    }
}
