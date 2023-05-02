using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HintBubble : MonoBehaviour
{
    [SerializeField] bool isTextLow = false;
    [SerializeField] bool enableDragonText = false;
    [SerializeField, TextArea(15,20)] string hintText = "TEST1";
    [SerializeField, TextArea(15, 20)] string dragonText = "UNUSED";

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            bool isADragon = false;
            PlayerCtrl playerTemp = other.gameObject.GetComponent<PlayerCtrl>();
            if (playerTemp != null && playerTemp.form.currentMode == CharacterMode.DRAGON) { isADragon = true; }
            ScreenText.SetTextReference((enableDragonText && isADragon ? dragonText : hintText), isTextLow, this.gameObject);
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            ScreenText.UnsetTextReference(this.gameObject);
        }
    }
}
