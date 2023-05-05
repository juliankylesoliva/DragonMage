using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HintBubble : MonoBehaviour, IInteractable
{
    SpriteRenderer spriteRenderer;

    [SerializeField] Color selectedColor;
    [SerializeField] bool isTextLow = false;
    [SerializeField] bool enableDragonText = false;
    [SerializeField] GameObject controlPrompt;
    [SerializeField, TextArea(15,20)] string hintText = "TEST1";
    [SerializeField, TextArea(15, 20)] string dragonText = "UNUSED";

    private PlayerCtrl player;
    private bool isTextShowing = false;

    void Awake()
    {
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    public void Interact(PlayerCtrl playerSrc)
    {
        if (player != null && playerSrc.gameObject.GetInstanceID() == player.gameObject.GetInstanceID())
        {
            if (!isTextShowing)
            {
                isTextShowing = true;
                bool isADragon = (player.form.currentMode == CharacterMode.DRAGON);
                ScreenText.SetTextReference((enableDragonText && isADragon ? dragonText : hintText), isTextLow, this.gameObject);
                spriteRenderer.color = selectedColor;
                controlPrompt.SetActive(false);
            }
            else
            {
                isTextShowing = false;
                ScreenText.UnsetTextReference(this.gameObject);
                spriteRenderer.color = Color.white;
                controlPrompt.SetActive(true);
            }
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            PlayerCtrl playerTemp = other.gameObject.GetComponent<PlayerCtrl>();
            if (playerTemp != null) { player = playerTemp; }
            player.interaction.SetInteractableRef(this);
            controlPrompt.SetActive(true);
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            player.interaction.UnsetInteractableRef(this);
            player = null;
            isTextShowing = false;
            spriteRenderer.color = Color.white;
            ScreenText.UnsetTextReference(this.gameObject);
            controlPrompt.SetActive(false);
        }
    }
}
