using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectFactory : MonoBehaviour
{
    [SerializeField] GameObject[] effectList;

    private static Dictionary<string, GameObject> effectDictionary;

    void Awake()
    {
        Initialize();
    }

    private void Initialize()
    {
        if (effectDictionary == null)
        {
            effectDictionary = new Dictionary<string, GameObject>();
            foreach (GameObject g in effectList)
            {
                effectDictionary.Add(g.name, g);
            }
        }
    }

    public static GameObject SpawnEffect(string effectName, Vector3 position)
    {
        if (effectDictionary != null && effectDictionary.ContainsKey(effectName))
        {
            return Instantiate(effectDictionary[effectName], position, Quaternion.identity);
        }
        return null;
    }
}
