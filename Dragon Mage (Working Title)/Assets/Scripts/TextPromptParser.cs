using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextPromptParser : MonoBehaviour
{
    public static string ParseTextPrompt(string rawString, string[] promptArray)
    {
        string retStr = rawString;

        for (int i = 0; i < promptArray.Length; ++i)
        {
            retStr = retStr.Replace($"[{i}]", $"<sprite=\"ControlGuide\" name=\"{promptArray[i]}\">");
        }

        return retStr;
    }
}
