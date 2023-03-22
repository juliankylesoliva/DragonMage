using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerTemper : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField, Range(3, 12)] int numSegments = 12;
    [SerializeField] int coldSegments = 3;
    [SerializeField] int hotSegments = 3;

    public int currentTemperLevel { get; private set; }
    public int coldThreshold { get; private set; }
    public int hotThreshold { get; private set; }
    public int NumSegments { get { return numSegments; } }

    public bool isFormLocked { get { return ((player.form.currentMode == CharacterMode.MAGE && currentTemperLevel <= coldThreshold) || (player.form.currentMode == CharacterMode.DRAGON && currentTemperLevel >= hotThreshold)); } }
    public bool forceFormChange { get { return ((player.form.currentMode == CharacterMode.MAGE && currentTemperLevel >= hotThreshold) || (player.form.currentMode == CharacterMode.DRAGON && currentTemperLevel <= coldThreshold)); } }

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        ValidateParameters();
    }

    private void ValidateParameters()
    {
        if (numSegments < 3)
        {
            numSegments = 3;
        }
        else if (numSegments > 12)
        {
            numSegments = 12;
        }
        else { /* Nothing */ }

        while ((coldSegments + hotSegments) >= numSegments)
        {
            if (coldSegments >= hotSegments)
            {
                coldSegments--;
            }
            else
            {
                hotSegments--;
            }
        }
        coldThreshold = coldSegments;
        hotThreshold = (numSegments - (hotSegments - 1));

        currentTemperLevel = ((coldThreshold + hotThreshold) / 2);
        UpdateMeterUI();
    }

    private void UpdateMeterUI()
    {
        if (TempMeterUI.isEventInstantiated) { TempMeterUI.temperChangeEvent.Invoke(); }
    }

    public void ChangeTemperBy(int num)
    {
        currentTemperLevel += num;

        if (currentTemperLevel < 1)
        {
            currentTemperLevel = 1;
        }
        else if (currentTemperLevel > numSegments)
        {
            currentTemperLevel = numSegments;
        }
        else { /* Nothing */ }

        UpdateMeterUI();
    }

    public void FormLockTemperChange()
    {
        if (currentTemperLevel >= hotThreshold)
        {
            currentTemperLevel = numSegments;
        }
        else if (currentTemperLevel <= coldThreshold)
        {
            currentTemperLevel = 1;
        }
        else { /* Nothing */ }

        UpdateMeterUI();
    }
}
